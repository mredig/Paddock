import XCTest
@testable import DockerClientSwift
import Logging

final class ContainerTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() {
        client = DockerClient.testable()
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
    }
    
    func testCreateContainers() async throws {
        let image = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        let id = try await client.containers.create(image: image)
        let container = try await client.containers.get(id)
        XCTAssertEqual(container.config.cmd, ["/hello"])
    }
    
    func testCreateContainers2() async throws {
        let _ = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        let spec = ContainerCreate(
            config: ContainerConfig(image: "hello-world:latest"),
            hostConfig: ContainerHostConfig()
        )
        try await client.containers.create(name: "tests", spec: spec)
    }
    
    func testUpdateContainers() async throws {
        let name = UUID.init().uuidString
        let _ = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        let spec = ContainerCreate(
            config: ContainerConfig(image: "hello-world:latest"),
            hostConfig: ContainerHostConfig()
        )
        let id = try await client.containers.create(name: name, spec: spec)
        try await client.containers.start(id)
        
        let newConfig = ContainerUpdate(memoryLimit: 64 * 1024 * 1024, memorySwap: 64 * 1024 * 1024)
        try await client.containers.update(id, spec: newConfig)
        
        let updated = try await client.containers.get(id)
        XCTAssert(updated.hostConfig.memoryLimit == 64 * 1024 * 1024, "Ensure param has been updated")
        
        try await client.containers.remove(id)
    }
    
    func testListContainers() async throws {
        let image = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        let _ = try await client.containers.create(image: image)
        
        let containers = try await client.containers.list(all: true)
    
        XCTAssert(containers.count >= 1)
        XCTAssert(containers.first!.createdAt > Date.distantPast)
        
    }
    
    func testInspectContainer() async throws {
        let image = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        let id = try await client.containers.create(image: image)
        let inspectedContainer = try await client.containers.get(id)
        
        XCTAssertEqual(inspectedContainer.id, id)
        XCTAssertEqual(inspectedContainer.config.cmd, ["/hello"])
    }
    
    func testStartingContainerAndRetrievingLogs() async throws {
        let image = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        let id = try await client.containers.create(image: image)
        let container = try await client.containers.get(id)
        try await client.containers.start(id)
        
        var output = ""
        for try await line in try await client.containers.logs(container: container, timestamps: true) {
            XCTAssert(line.timestamp != Date.distantPast, "Ensure timestamp is parsed properly")
            XCTAssert(line.source == .stdout, "Ensure stdout is properly detected")
            output += line.message + "\n"
        }
        // arm64v8 or amd64
        XCTAssertEqual(
            output,
        """

        Hello from Docker!
        This message shows that your installation appears to be working correctly.
        
        To generate this message, Docker took the following steps:
         1. The Docker client contacted the Docker daemon.
         2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
            (arm64v8)
         3. The Docker daemon created a new container from that image which runs the
            executable that produces the output you are currently reading.
         4. The Docker daemon streamed that output to the Docker client, which sent it
            to your terminal.
        
        To try something more ambitious, you can run an Ubuntu container with:
         $ docker run -it ubuntu bash
        
        Share images, automate workflows, and more with a free Docker ID:
         https://hub.docker.com/
        
        For more examples and ideas, visit:
         https://docs.docker.com/get-started/
        
        
        """
        )
    }
    
    // Log entries parsing is quite different depending on whether the container has a TTY
    func testStartingContainerAndRetrievingLogsTty() async throws {
        let image = try await client.images.pullImage(byName: "hello-world", tag: "latest")
        let id = try await client.containers.create(
            name: nil,
            spec: ContainerCreate(
                config: ContainerConfig(image: image.id.value, tty: true),
                hostConfig: .init())
        )
        let container = try await client.containers.get(id)
        try await client.containers.start(id)
        
        var output = ""
        for try await line in try await client.containers.logs(container: container, timestamps: true) {
            XCTAssert(line.timestamp != Date.distantPast, "Ensure timestamp is parsed properly")
            XCTAssert(line.source == .stdout, "Ensure stdout is properly detected")
            output += line.message + "\n"
        }
        // arm64v8 or amd64
        XCTAssertEqual(
            output,
        """
        
        Hello from Docker!
        This message shows that your installation appears to be working correctly.
        
        To generate this message, Docker took the following steps:
         1. The Docker client contacted the Docker daemon.
         2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
            (arm64v8)
         3. The Docker daemon created a new container from that image which runs the
            executable that produces the output you are currently reading.
         4. The Docker daemon streamed that output to the Docker client, which sent it
            to your terminal.
        
        To try something more ambitious, you can run an Ubuntu container with:
         $ docker run -it ubuntu bash
        
        Share images, automate workflows, and more with a free Docker ID:
         https://hub.docker.com/
        
        For more examples and ideas, visit:
         https://docs.docker.com/get-started/
        
        
        """
        )
    }
    
    func testPruneContainers() async throws {
        let image = try await client.images.pullImage(byName: "nginx", tag: "latest")
        let id = try await client.containers.create(image: image)
        try await client.containers.start(id)
        try await client.containers.stop(id)
        
        let pruned = try await client.containers.prune()
        
        let containers = try await client.containers.list(all: true)
        XCTAssert(!containers.map(\.id).contains(id))
        XCTAssert(pruned.reclaimedSpace > 0)
        XCTAssert(pruned.containersIds.contains(id))
    }
}
