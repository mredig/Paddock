import Foundation
import NIO
import NIOHTTP1
import NIOSSL
import AsyncHTTPClient
import Logging

extension HTTPClient {
    /// Executes a HTTP request on a socket.
    /// - Parameters:
    ///   - method: HTTP method.
    ///   - socketPath: The path to the unix domain socket to connect to.
    ///   - urlPath: The URI path and query that will be sent to the server.
    ///   - body: Request body.
    ///   - deadline: Point in time by which the request must complete.
    ///   - logger: The logger to use for this request.
    ///   - headers: Custom HTTP headers.
    /// - Returns: Returns an `EventLoopFuture` with the `Response` of the request
    public func execute(_ method: HTTPMethod = .GET, daemonURL: URL, urlPath: String, body: Body? = nil, tlsConfig: TLSConfiguration?, deadline: NIODeadline? = nil, logger: Logger, headers: HTTPHeaders) -> EventLoopFuture<Response> {
        do {
            guard let url = URL(string: daemonURL.absoluteString.trimmingCharacters(in: .init(charactersIn: "/")) + urlPath) else {
                throw HTTPClientError.invalidURL
            }
            
            let request = try Request(url: url, method: method, headers: headers, body: body, tlsConfiguration: tlsConfig)
            return self.execute(request: request, deadline: deadline, logger: logger)
        } catch {
            return self.eventLoopGroup.next().makeFailedFuture(error)
        }
    }
    
    public func executeStream(_ method: HTTPMethod = .GET, daemonURL: URL, urlPath: String, body: HTTPClientRequest.Body? = nil, tlsConfig: TLSConfiguration?, timeout: TimeAmount, logger: Logger, headers: HTTPHeaders) async throws -> HTTPClientResponse.Body {
        
        guard let url = URL(string: daemonURL.absoluteString.trimmingCharacters(in: .init(charactersIn: "/")) + urlPath) else {
            throw HTTPClientError.invalidURL
        }
        
        var request = HTTPClientRequest(url: url.absoluteString)
        request.headers = headers
        request.method = method
        request.body = body
        
        let response = try await self.execute(request, timeout: timeout)
        //let response = try await self.execute(request, deadline: deadline ?? .now() + TimeAmount.seconds(10), logger: logger)
        return response.body
    }
    
    internal func executeStream2(_ method: HTTPMethod = .GET, daemonURL: URL, urlPath: String, body: HTTPClientRequest.Body? = nil, tlsConfig: TLSConfiguration?, timeout: TimeAmount, logger: Logger, headers: HTTPHeaders) async throws -> AsyncThrowingStream<Data, Error> {
        
        guard let url = URL(string: daemonURL.absoluteString.trimmingCharacters(in: .init(charactersIn: "/")) + urlPath) else {
            throw HTTPClientError.invalidURL
        }
        
        var request = HTTPClientRequest(url: url.absoluteString)
        request.headers = headers
        request.method = method
        request.body = body
        
        let response = try await self.execute(request, timeout: timeout)
        let body = response.body
        return AsyncThrowingStream<Data, Error> { continuation in
            _Concurrency.Task {
                for try await buffer in body {
                    let data = Data(buffer: buffer)
                    continuation.yield(data)
                }
                continuation.finish()
            }
        }
    }
    
    
    /*public func execute(_ method: HTTPMethod = .GET, daemonURL: URL, urlPath: String, body: Body? = nil, tlsConfig: TLSConfiguration?, deadline: NIODeadline? = nil, logger: Logger, headers: HTTPHeaders) async throws -> Response {
        guard let url = URL(string: daemonURL.absoluteString.trimmingCharacters(in: .init(charactersIn: "/")) + urlPath) else {
            throw HTTPClientError.invalidURL
        }
        
        let request = try Request(url: url, method: method, headers: headers, body: body, tlsConfiguration: tlsConfig)
        return try await self.execute(request: request, deadline: deadline, logger: logger).get()
        
    }*/
}
