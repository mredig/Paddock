import Foundation

extension PaddockClient {
	
	/// APIs related to Docker networks.
	public var networks: NetworksAPI {
		.init(client: self)
	}
	
	public struct NetworksAPI {
		fileprivate var client: PaddockClient
		
		/// Lists the networks.
		/// - Throws: Errors that can occur when executing the request.
		/// - Returns: Returns  a  list of `Network`.
		public func list() async throws -> [Network] {
			return try await client.run(ListNetworksEndpoint())
		}
		
		
		/// Gets a Network by a given name or id.
		/// - Parameter nameOrId: Name or id of a `Network` that should be fetched.
		/// - Throws: Errors that can occur when executing the request.
		/// - Returns: Return the `Network`.
		public func get(_ nameOrId: String) async throws -> Network {
			return try await client.run(InspectNetworkEndpoint(nameOrId: nameOrId, logger: client.logger))
		}

		/// Create a new Network.
		/// - Parameters:
		///   - spec: configuration as a `NetworkSpec`.
		/// - Throws: Errors that can occur when executing the request.
		/// - Returns: Returns the newly created `Network` info object.
		public func create(spec: CreateNetworkEndpoint.NetworkSpec) async throws -> CreateNetworkEndpoint.Response {
			try await client.run(CreateNetworkEndpoint(spec: spec, logger: client.logger))
		}
	
		/// Removes an existing Network.
		/// - Parameters:
		///   - nameOrId: Name or Id of the`Network`.
		/// - Throws: Errors that can occur when executing the request.
		public func remove(_ nameOrId: String) async throws {
			try await client.run(RemoveNetworkEndpoint(nameOrId: nameOrId))
		}
		
		/// Deletes all unused networks.
		/// - Throws: Errors that can occur when executing the request.
		/// - Returns: Returns the list of **names** of the networks that got deleted.
		/// - SeeAlso: https://docs.docker.com/engine/api/v1.41/#operation/NetworkPrune
		public func prune() async throws -> PruneNetworksEndpoint.Response {
			return try await client.run(PruneNetworksEndpoint())
		}
		
		/// Connects a Container to an existing Network.
		/// - Parameters:
		///   - container: Name or Id of the`Container`.
		///   - to: Name or Id of the`Network`.
		///   - endpointSettings: Configures the network endpoint (IP Address...)
		/// - Throws: Errors that can occur when executing the request.
		public func connect(container: String, to networkId: String, endpointSettings: ConnectContainerNetworkEndpoint.ConnectSettings.EndpointSettings? = nil) async throws {
			try await client.run(
				ConnectContainerNetworkEndpoint(
					networkNameOrId: networkId,
					connectConfig: .init(container: container, endpointConfig: endpointSettings)
				)
			)
		}
		
		/// Disconnects an existing Container from a Network.
		/// - Parameters:
		///   - container: Name or Id of the`Container` to disconnect.
		///   - from: Name or Id of the`Network`.
		///   - force: Force disconnection.
		/// - Throws: Errors that can occur when executing the request.
		public func disconnect(container: String, from networkNameOrId: String, force: Bool = false) async throws {
			try await client.run(
				DisconnectContainerNetworkEndpoint(nameOrId: networkNameOrId, containerNameOrId: container, force: force)
			)
		}
	}
}
