import Foundation

extension PaddockClient {
	
	/// APIs related to Docker volumes.
	public var volumes: VolumesAPI {
		.init(client: self)
	}
	
	public struct VolumesAPI {
		fileprivate var client: PaddockClient
		
		
		/// Lists the volumes.
		/// - Throws: Errors that can occur when executing the request.
		/// - Returns: Returns  a  list of `Volume`.
		public func list() async throws -> ListVolumesEndpoint.Response {
			let response = try await client.run(ListVolumesEndpoint())
			return response
		}
		
		/// Gets a Volume by a given name or id.
		/// - Parameter nameOrId: Name or id of a volume that should be fetched.
		/// - Throws: Errors that can occur when executing the request.
		/// - Returns: Return the `Volume`.
		public func get(_ nameOrId: String) async throws -> Volume {
			return try await client.run(InspectVolumeEndpoint(nameOrId: nameOrId))
		}
		
		/// Create a new Volume.
		/// - Parameters:
		///   - spec: configuration as a `VolumeSpec`.
		/// - Throws: Errors that can occur when executing the request.
		/// - Returns: Returns the newly created `Volume`.
		public func create(spec: CreateVolumeEndpoint.Body) async throws -> Volume {
			return try await client.run(CreateVolumeEndpoint(spec: spec, logger: client.logger))
		}
		
		/// Removes an existing Volume.
		/// - Parameters:
		///   - nameOrId: Name or Id of the`Volume`.
		///   - force: Force removal.
		/// - Throws: Errors that can occur when executing the request.
		public func remove(_ nameOrId: String, force: Bool = false) async throws {
			try await client.run(RemoveVolumeEndpoint(nameOrId: nameOrId, force: force))
		}
		
		/// Deletes all unused volumes.
		/// - Throws: Errors that can occur when executing the request.
		/// - Returns: Returns a `PrunedVolumes` details about removed volumes and the reclaimed space.
		public func prune(all: Bool = false) async throws -> PruneVolumesEndpoint.Response {
			return try await client.run(PruneVolumesEndpoint())
		}
	}
}
