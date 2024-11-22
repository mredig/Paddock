import Foundation
import NIO

extension DockerClient {
    
    /// APIs related to images.
    public var images: ImagesAPI {
        .init(client: self)
    }
    
    public struct ImagesAPI {
        fileprivate var client: DockerClient
        
        /// Pulls an image from a remote registry
        /// If you want to customize the identifier of the image you can use `pullImage(byIdentifier:)` to do this.
        /// - Parameters:
        ///   - name: Image name that is fetched
        ///   - tag: Optional tag name. Default is `nil`.
        ///   - digest: Optional digest value. Default is `nil`.
        ///   - credentials: Optional `RegistryAuth` as returned by `registries.login()`
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Fetches the latest image information and returns the `Image` that has been fetched.
        public func pull(byName name: String, tag: String? = nil, digest: Digest? = nil, credentials: RegistryAuth? = nil) async throws -> Image {
            var identifier = name
            if let tag = tag {
                identifier += ":\(tag)"
            }
            if let digest = digest {
                identifier += "@\(digest.rawValue)"
            }
            return try await pull(byIdentifier: identifier, credentials: credentials)
        }
        
        /// Pulls an image by a given identifier. The identifier can be build manually.
        /// - Parameters:
        ///   - identifier: Identifier of an image that is pulled.
        ///   - credentials: Optional `RegistryAuth` as returned by `registries.login()`
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Fetches the latest image information and returns the `Image` that has been fetched.
        public func pull(byIdentifier identifier: String, credentials: RegistryAuth? = nil) async throws -> Image {
            try await client.run(PullImageEndpoint(imageName: identifier, credentials: credentials, logger: client.logger))
            return try await self.get(identifier)
        }
        
        /// Push an image to a registry.
        /// - Parameters:
        ///   - nameOrId: Name or ID of the `Image` that should be pushed.
        ///   - tag: The tag to associate with the image on the registry. If you wish to push an image on to a private registry, that image must already have a tag which references the registry. For example, registry.example.com/myimage:latest.
        ///   - credentials: Optional `RegistryAuth` as returned by `registries.login()`
        /// - Throws: Errors that can occur when executing the request.
        public func push(_ nameOrId: String, tag: String? = nil, credentials: RegistryAuth? = nil) async throws {
            try await client.run(PushImageEndpoint(nameOrId: nameOrId, tag: tag, credentials: credentials))
        }
        
        /// Gets all images in the Docker system.
        /// - Parameter all: If `true` intermediate image layer will be returned as well. Default is `false`.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns a list of `Image` instances.
        public func list(all: Bool = false) async throws -> [ImageSummary] {
            return try await client.run(ListImagesEndpoint(all: all))
        }
        
        /// Removes an image. By default only unused images can be removed. If you set `force` to `true` the image will also be removed if it is used.
        /// - Parameters:
        ///   - nameOrId: Name or ID of an `Image` that should be removed.
        ///   - force: Should the image be removed by force? If `false` the image will only be removed if it's unused. If `true` existing containers will break. Default is `false`.
        /// - Throws: Errors that can occur when executing the request.
        public func remove(_ nameOrId: String, force: Bool = false) async throws {
            try await client.run(RemoveImageEndpoint(nameOrId: nameOrId, force: force))
        }
        
        /// Fetches the current information about an image from the Docker system.
        /// - Parameter nameOrId: Name or id of an image that should be fetched.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns the `Image` data.
        public func get(_ nameOrId: String) async throws -> Image {
            return try await client.run(InspectImagesEndpoint(nameOrId: nameOrId))
        }
        
        /// Fetches the history (layers) information for an image.
        /// - Parameter nameOrId: Name or id of an image that should be fetched.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns a list of `ImageLayer`. Layers are sorted from uuswer to
        public func history(_ nameOrId: String) async throws -> [ImageLayer] {
            return try await client.run(GetImageHistoryEndpoint(nameOrId: nameOrId))
        }
        
        /// Builds an image.
        /// - Parameters:
        ///   - config: A `BuildConfig` instance specifying build options.
        ///   - context: A `ByteBuffer` containing a **TAR archive** of the Docker Build context (Dockerfile + any other content needed to build the image).
        ///   - timeout: How long to wait for the build to finish before cancelling it (by cancelling the request).
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` when the image has been removed or an error is thrown.
        public func build(config: BuildConfig, context: ByteBuffer, timeout: TimeAmount = .minutes(10)) async throws -> AsyncThrowingStream<BuildStreamOutput, Error> {
            let endpoint = BuildEndpoint(buildConfig: config, context: context)
            let response =  try await client.run(endpoint, timeout: timeout, separators: [UInt8(ascii: "}"), UInt8(13)])
            return try await endpoint.map(response: response)
        }
        
        /// Creates an image from an existing Container (`docker commit`).
        /// - Parameters:
        ///   - nameOrId: Name or id of the Container that should be used to build the Image.
        ///   - spec: A optional `ContainerConfig`.
        ///   - pause: Whether to pause the Container during the Image creation, defaults to `true`.
        ///   - repo: Optional Repository name to give to the resulting image.
        ///   - tag: Optional Tag name to give to the resulting image.
        ///   - comment: An optional commit message.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `Image` when the image has been built, or an error is thrown.
        public func createFromContainer(_ nameOrId: String, spec: ContainerConfig? = nil, pause: Bool = true, repo: String? = nil, tag: String? = nil, comment: String? = nil) async throws -> Image {
            let ep = CommitContainerEndpoint(nameOrId: nameOrId, spec: spec, pause: pause, repo: repo, tag: tag, comment: comment)
            let response = try await client.run(ep)
            return try await get(response.Id)
        }
        
        /// Tags an image.
        /// - Parameters:
        ///   - nameOrId: Name or ID of the image to tag.
        ///   - repoName: The repository name. (can optionally start with a registry endpoint)
        ///   - tag: The tag name. Defaults to "latest"..
        /// - Throws: Errors that can occur when executing the request.
        public func tag(_ nameOrId: String, repoName: String, tag: String = "latest") async throws {
            try await client.run(TagImageEndpoint(nameOrId: nameOrId, repoName: repoName, tag: tag))
        }
        
        /// Deletes all unused images.
        /// - Parameter all: When set to `true`, prune only unused and untagged images. When set to `false`, all unused images are pruned.
        /// - Throws: Errors that can occur when executing the request.
        /// - Returns: Returns an `EventLoopFuture` with `PrunedImages` details about removed images and the reclaimed space.
        public func prune(all: Bool = false) async throws -> PrunedImages {
            let response = try await client.run(PruneImagesEndpoint(dangling: !all))
            return PrunedImages(
                imageIds: response.ImagesDeleted?.compactMap(\.Deleted) ?? [],
                reclaimedSpace: response.SpaceReclaimed
            )
        }
        
        public struct PrunedImages {
            /// IDs of the images that got deleted.
            let imageIds: [String]
            
            /// Disk space reclaimed in bytes.
            let reclaimedSpace: UInt64
        }
    }
}

/// Representation of an image digest.
public struct Digest : Codable {
    public var rawValue: String
    
    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension Digest: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

/*extension Image {
    /// Parses an image identifier to it's corresponding digest, name and tag.
    /// - Parameter value: Image identifer.
    /// - Returns: Returns an `Optional` tuple of a `Digest` and a `RepositoryTag`.
    internal static func parseNameTagDigest(_ value: String) -> (Digest, RepositoryTag)? {
        let components = value.split(separator: "@").map(String.init)
        if components.count == 2, let nameTag = RepositoryTag(components[0]) {
            return (.init(components[1]), nameTag)
        } else {
            return nil
        }
    }
}*/
