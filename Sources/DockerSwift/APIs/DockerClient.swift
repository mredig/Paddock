import Foundation
import NIO
import NIOHTTP1
import NIOSSL
import AsyncHTTPClient
import Logging

/// The entry point for Docker client commands.
public class DockerClient {
	internal let apiVersion = "v1.41"
	private let headers = HTTPHeaders([
		("Host", "localhost"), // Required by Docker
		("Accept", "application/json;charset=utf-8"),
		("Content-Type", "application/json")
	])
	private let decoder: JSONDecoder
	
	internal let daemonURL: URL
	internal let tlsConfig: TLSConfiguration?
	internal let client: HTTPClient
	internal let logger: Logger

	package let testMode: TestMode

	public private(set) var state: State = .uninitialized

	/// Initialize the `DockerClient`.
	/// - Parameters:
	///   - daemonURL: The URL where the Docker API is listening on. Default is `http+unix:///var/run/docker.sock`.
	///   - tlsConfig: `TLSConfiguration` for a Docker daemon requiring TLS authentication. Default is `nil`.
	///   - logger: `Logger` for the `DockerClient`. Default is `.init(label: "docker-client")`.
	///   - clientThreads: Number of threads to use for the HTTP client EventLoopGroup. Defaults to 2.
	///   - timeout: Pass custom connect and read timeouts via a `HTTPClient.Configuration.Timeout` instance
	///   - proxy: Proxy settings, defaults to `nil`.
	public convenience init(
		daemonURL: URL = URL(httpURLWithSocketPath: DockerEnvironment.dockerHost)!,
		tlsConfig: TLSConfiguration? = nil,
		logger: Logger = .init(label: "🪵docker-client"),
		clientThreads: Int = 2,
		timeout: HTTPClient.Configuration.Timeout = .init(),
		proxy: HTTPClient.Configuration.Proxy? = nil
	) {
		self.init(
			daemonURL: daemonURL,
			tlsConfig: tlsConfig,
			logger: logger,
			clientThreads: clientThreads,
			timeout: timeout,
			proxy: proxy,
			testMode: .live)
	}

	package static func forTesting(
		daemonURL: URL = URL(httpURLWithSocketPath: DockerEnvironment.dockerHost)!,
		tlsConfig: TLSConfiguration? = nil,
		clientThreads: Int = 2,
		timeout: HTTPClient.Configuration.Timeout = .init(),
		proxy: HTTPClient.Configuration.Proxy? = nil,
		useLiveSocket: Bool = false
	) -> DockerClient {
		var logger = Logger(label: "🪵docker-client-tests")
		logger.logLevel = .debug

		return DockerClient(
			daemonURL: daemonURL,
			tlsConfig: tlsConfig,
			logger: logger,
			clientThreads: clientThreads,
			timeout: timeout,
			proxy: proxy,
			testMode: .testing(useMocks: !useLiveSocket))
	}

	private init(
		daemonURL: URL = URL(httpURLWithSocketPath: DockerEnvironment.dockerHost)!,
		tlsConfig: TLSConfiguration? = nil,
		logger: Logger = .init(label: "🪵docker-client"),
		clientThreads: Int = 2,
		timeout: HTTPClient.Configuration.Timeout = .init(),
		proxy: HTTPClient.Configuration.Proxy? = nil,
		testMode: TestMode
	) {
		self.daemonURL = daemonURL
		self.tlsConfig = tlsConfig
		let clientConfig = HTTPClient.Configuration(
			tlsConfiguration: tlsConfig,
			timeout: timeout,
			proxy: proxy,
			ignoreUncleanSSLShutdown: true
		)
		let httpClient = HTTPClient(
			eventLoopGroupProvider: .shared(MultiThreadedEventLoopGroup(numberOfThreads: clientThreads)),
			configuration: clientConfig
		)
		self.client = httpClient
		self.logger = logger
		self.testMode = testMode

		let decoder = JSONDecoder()
		self.decoder = decoder
	}

	public func initialize() async throws {
		_ = try await _initialize().value
	}

	@MainActor
	private func _initialize() -> Task<HostInfo, Error> {
		if let existing = State.stateRetrievalTask {
			return existing
		} else {
			let newTask = Task {
				let version = try await version()

				let info: HostInfo? = {
					guard
						let component = version.components.first(where: { $0.details?.arch != nil }),
						let details = component.details
					else { return nil }
					let isExperimental = details.experimental == "true"
					let engine = HostInfo.HostEngine(rawValue: component.name)
					let arch = version.arch
					let os = version.os
					let engineVersion = version.version

					return HostInfo(
						architecture: arch,
						version: engineVersion,
						isExperimentalBuild: isExperimental,
						os: os,
						engine: engine)
				}()
				guard
					let info
				else { throw DockerError.message("Failed to retrieve Docker host information.") }

				self.state = .initialized(info)

				return info
			}
			State.stateRetrievalTask = newTask
			return newTask
		}
	}

	/// The client needs to be shutdown otherwise it can crash on exit.
	/// - Throws: Throws an error if the `DockerClient` can not be shutdown.
	public func syncShutdown() throws {
		defer { state = .uninitialized }
		try client.syncShutdown()
	}
	
	/// The client needs to be shutdown otherwise it can crash on exit.
	/// - Throws: Throws an error if the `DockerClient` can not be shutdown.
	public func shutdown() async throws {
		defer { state = .uninitialized }
		try await client.shutdown()
	}

	func genCurlCommand<E: SimpleEndpoint>(_ endpoint: E) throws -> String {
		try genCurlCommand(
			method: endpoint.method,
			path: endpoint.path,
			queryItems: endpoint.queryArugments,
			headers: endpoint.headers,
			body: endpoint.body)
	}

	func genCurlCommand<E: StreamingEndpoint>(_ endpoint: E) throws -> String {
		try genCurlCommand(
			method: endpoint.method,
			path: endpoint.path,
			queryItems: endpoint.queryArugments,
			headers: nil,
			body: endpoint.body)
	}

	func genCurlCommand<E: UploadEndpoint>(_ endpoint: E) throws -> String {
		try genCurlCommand(
			method: endpoint.method,
			path: endpoint.path,
			queryItems: endpoint.queryArugments,
			headers: nil,
			body: endpoint.body)
	}

	private func genCurlCommand<Body: Codable>(
		method: HTTPMethod,
		path: String,
		queryItems: [URLQueryItem],
		headers: HTTPHeaders?,
		body: Body?
	) throws -> String {
		var finalHeaders: HTTPHeaders = self.headers
		if let additionalHeaders = headers {
			finalHeaders.add(contentsOf: additionalHeaders)
		}

		let curlHeaders: String? = {
			let headers = finalHeaders
				.map { "-H \"\($0.name): \($0.value)\"" }
				.joined(separator: " ")
			guard headers.isEmpty == false else {
				return nil
			}
			return headers
		}()
		let curlBody: String? = try {
			if let body = body {
				let data = String(decoding: try body.encode(), as: UTF8.self)
					.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
				return "-d \"\(data)\""
			} else {
				return nil
			}
		}()
		let url = {
			var new = URL(string: "http://localhost/")!
				.appending(component: "\(apiVersion)")
				.appending(path: path)
			if queryItems.isEmpty == false {
				new
				.append(queryItems: queryItems)
			}
			return new
		}()
		let curlUnixSocket = "${DOCKER_HOST}"
		let curlCommand = """
			curl \
			--unix-socket "\(curlUnixSocket)" \
			"\(url.absoluteString)" \
			-X \(method.rawValue)
			"""

		let final = [curlCommand, curlHeaders, curlBody]
			.compactMap(\.self)
			.joined(separator: " ")
		return final
	}

	/// Executes a request to a specific endpoint. The `Endpoint` struct provides all necessary data and parameters for the request.
	/// - Parameter endpoint: `Endpoint` instance with all necessary data and parameters.
	/// - Throws: It can throw an error when encoding the body of the `Endpoint` request to JSON.
	/// - Returns: Returns the expected result definied by the `Endpoint`.
	@discardableResult
	internal func run<T: SimpleEndpoint>(_ endpoint: T) async throws -> T.Response {
		if case .uninitialized = state, type(of: endpoint) != VersionEndpoint.self {
			try await initialize()
		}
		var finalHeaders: HTTPHeaders = self.headers
		if let additionalHeaders = endpoint.headers {
			finalHeaders.add(contentsOf: additionalHeaders)
		}
		defer {
			if logger.logLevel <= .debug {
				// printing to avoid the logging prefix, making for an easier copy/pasta
				try? print("💻⭐️\n\(genCurlCommand(endpoint))\n")
			}
		}

		let request = try HTTPClientRequest(
			daemonURL: daemonURL,
			urlPath: "/\(apiVersion)/\(endpoint.path)",
			queryItems: endpoint.queryArugments,
			method: endpoint.method,
			body: endpoint.body.map { try HTTPClientRequest.Body.bytes($0.encode()) },
			headers: finalHeaders)

		func decodeOut(_ buffer: ByteBuffer) throws -> T.Response {
			if T.Response.self == NoBody.self || T.Response.self == NoBody?.self {
				return NoBody() as! T.Response
			}
			guard T.Response.self != String.self else {
				return String(buffer: buffer) as! T.Response
			}
			return try decoder.decode(T.Response.self, from: buffer)
		}

		if case .testing(useMocks: let useMocks) = testMode{
			if useMocks {
				if let mockEndpoint = endpoint as? (any MockedResponseEndpoint) {
					logger.debug("(\(T.self) / \(T.Response.self)) 🍀🍀 Mocked \(endpoint.method.rawValue) \(endpoint.path)")
					let buffer = try await mockEndpoint.mockedResponse(request)
					return try decodeOut(buffer)
				} else {
					logger.debug("(\(T.self) / \(T.Response.self)) 🤬🥵 Not Mocked \(endpoint.method.rawValue) \(endpoint.path)")
				}
			} else {
				logger.debug("(\(T.self) / \(T.Response.self)) ⚡️🔌 Live Socket Testing \(endpoint.method.rawValue) \(endpoint.path)")
			}
		}

		let response = try await client.execute(request, timeout: .minutes(2))
		let responseBody = response.body
		try response.checkStatusCode()

		let buffer = try await responseBody.collect(upTo: .max)

		if logger.logLevel <= .debug {
			var debugResponseCopy = buffer
			logger.debug("Response: \(debugResponseCopy.readString(length: debugResponseCopy.readableBytes) ?? "No Response Data")")
		}
		return try decodeOut(buffer)
	}
	
	/// Executes a request to a specific endpoint. The `PipelineEndpoint` struct provides all necessary data and parameters for the request.
	/// The difference for between `Endpoint` and `EndpointPipeline` is that the second one needs to provide a function that transforms the response as a `String` to the expected result.
	/// - Parameter endpoint: `PipelineEndpoint` instance with all necessary data and parameters.
	/// - Throws: It can throw an error when encoding the body of the `PipelineEndpoint` request to JSON.
	/// - Returns: Returns the expected result definied and transformed by the `PipelineEndpoint`.
	@discardableResult
	internal func run<T: PipelineEndpoint>(_ endpoint: T) async throws -> T.Response {
		if case .uninitialized = state, type(of: endpoint) != VersionEndpoint.self {
			try await initialize()
		}
		defer {
			if logger.logLevel <= .debug {
				// printing to avoid the logging prefix, making for an easier copy/pasta
				try? print("💻⭐️\n\(genCurlCommand(endpoint))\n")
			}
		}

		let request = try HTTPClientRequest(
			daemonURL: daemonURL,
			urlPath: "/\(apiVersion)/\(endpoint.path)",
			queryItems: endpoint.queryArugments,
			method: endpoint.method,
			body: endpoint.body.map { try HTTPClientRequest.Body.bytes($0.encode()) },
			headers: headers)

		func decodeOut(_ buffer: ByteBuffer) throws -> T.Response {
			var buffer = buffer
			guard
				let bufferString = buffer.readString(length: buffer.readableBytes)
			else { throw DockerError.corruptedData("Expected a string") }

			return try endpoint.map(data: bufferString)
		}

		if case .testing(useMocks: let useMocks) = testMode{
			if useMocks {
				if let mockEndpoint = endpoint as? (any MockedResponseEndpoint) {
					logger.debug("(\(T.self) / \(T.Response.self)) 🍀🍀 Mocked \(endpoint.method.rawValue) \(endpoint.path)")
					let buffer = try await mockEndpoint.mockedResponse(request)
					return try decodeOut(buffer)
				} else {
					logger.debug("(\(T.self) / \(T.Response.self)) 🤬🥵 Not Mocked \(endpoint.method.rawValue) \(endpoint.path)")
				}
			} else {
				logger.debug("(\(T.self) / \(T.Response.self)) ⚡️🔌 Live Socket Testing \(endpoint.method.rawValue) \(endpoint.path)")
			}
		}

		let response = try await client.execute(request, timeout: .minutes(2))
		let responseBody = response.body

		let buffer = try await responseBody.collect(upTo: .max)

		if logger.logLevel <= .debug {
			var debugResponseCopy = buffer
			logger.debug("Response: \(debugResponseCopy.readString(length: debugResponseCopy.readableBytes) ?? "No Response Data")")
		}

		return try decodeOut(buffer)
	}
	
	@discardableResult
	internal func run<T: StreamingEndpoint>(_ endpoint: T, timeout: TimeAmount, hasLengthHeader: Bool, separators: [UInt8]) async throws -> T.Response {
		if case .uninitialized = state, type(of: endpoint) != VersionEndpoint.self {
			try await initialize()
		}
		defer {
			if logger.logLevel <= .debug {
				// printing to avoid the logging prefix, making for an easier copy/pasta
				try? print("💻⭐️\n\(genCurlCommand(endpoint))\n")
			}
		}

		let request = try HTTPClientRequest(
			daemonURL: daemonURL,
			urlPath: "/\(apiVersion)/\(endpoint.path)",
			queryItems: endpoint.queryArugments,
			method: endpoint.method,
			body: endpoint.body.map { try HTTPClientRequest.Body.bytes($0.encode()) },
			headers: headers)

		if case .testing(useMocks: let useMocks) = testMode{
			if useMocks {
				if let mockEndpoint = endpoint as? (any MockedResponseEndpoint) {
					logger.debug("(\(T.self) / \(T.Response.self)) 🍀🍀 Mocked \(endpoint.method.rawValue) \(endpoint.path)")
					return try await mockEndpoint.mockedStreamingResponse(request)
				} else {
					logger.debug("(\(T.self) / \(T.Response.self)) 🤬🥵 Not Mocked \(endpoint.method.rawValue) \(endpoint.path)")
				}
			} else {
				logger.debug("(\(T.self) / \(T.Response.self)) ⚡️🔌 Live Socket Testing \(endpoint.method.rawValue) \(endpoint.path)")
			}
		}

		let stream = try await client.executeStream(request: request, timeout: timeout, logger: logger)
		return stream
	}
	
	@discardableResult
	internal func run<T: UploadEndpoint>(_ endpoint: T, timeout: TimeAmount, separators: [UInt8]) async throws -> T.Response {
		if case .uninitialized = state, type(of: endpoint) != VersionEndpoint.self {
			try await initialize()
		}
		defer {
			if logger.logLevel <= .debug {
				// printing to avoid the logging prefix, making for an easier copy/pasta
				try? print("💻⭐️\n\(genCurlCommand(endpoint))\n")
			}
		}

		let request = HTTPClientRequest(
			daemonURL: daemonURL,
			urlPath: "/\(apiVersion)/\(endpoint.path)",
			queryItems: endpoint.queryArugments,
			method: endpoint.method,
			body: endpoint.body.map { HTTPClientRequest.Body.bytes($0) },
			headers: headers)


		if case .testing(useMocks: let useMocks) = testMode{
			if useMocks {
				if let mockEndpoint = endpoint as? (any MockedResponseEndpoint) {
					logger.debug("(\(T.self) / \(T.Response.self)) 🍀🍀 Mocked \(endpoint.method.rawValue) \(endpoint.path)")
					return try await mockEndpoint.mockedStreamingResponse(request)
				} else {
					logger.debug("(\(T.self) / \(T.Response.self)) 🤬🥵 Not Mocked \(endpoint.method.rawValue) \(endpoint.path)")
				}
			} else {
				logger.debug("(\(T.self) / \(T.Response.self)) ⚡️🔌 Live Socket Testing \(endpoint.method.rawValue) \(endpoint.path)")
			}
		}

		return try await client.executeStream(request: request, timeout: timeout, logger: logger)
	}

	package enum TestMode {
		case live
		case testing(useMocks: Bool)
	}
}
