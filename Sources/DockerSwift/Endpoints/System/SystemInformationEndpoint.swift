import NIOHTTP1

struct SystemInformationEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = SystemInformation

	var method: HTTPMethod = .GET
	let path: String = "info"
}

extension SystemInformationEndpoint: MockedResponseEndpoint {
	var responseData: [MockedResponseData] {
		[
			.string("""
				{"ID":"3d0d48a6-ac77-486b-8506-88b2e79dbde5","Containers":0,"ContainersRunning":0,"ContainersPaused":0,"ContainersStopped":0,"Images":2,"Driver":"overlay","DriverStatus":[["Backing Filesystem","xfs"],["Supports d_type","true"],["Native Overlay Diff","true"],["Using metacopy","false"],["Supports shifting","false"],["Supports volatile","true"]],"Plugins":{"Volume":["local"],"Network":["bridge","macvlan","ipvlan"],"Authorization":null,"Log":["k8s-file","none","passthrough","journald"]},"MemoryLimit":true,"SwapLimit":false,"CpuCfsPeriod":false,"CpuCfsQuota":false,"CPUShares":false,"CPUSet":false,"PidsLimit":true,"IPv4Forwarding":false,"BridgeNfIptables":false,"BridgeNfIp6tables":false,"Debug":false,"NFd":12,"OomKillDisable":false,"NGoroutines":14,"SystemTime":"2024-11-22T02:45:53.933054116-06:00","LoggingDriver":"","CgroupDriver":"systemd","NEventsListener":0,"KernelVersion":"6.10.10-200.fc40.aarch64","OperatingSystem":"fedora","OSVersion":"40","OSType":"linux","Architecture":"arm64","IndexServerAddress":"","RegistryConfig":{"AllowNondistributableArtifactsCIDRs":[],"AllowNondistributableArtifactsHostnames":[],"InsecureRegistryCIDRs":[],"IndexConfigs":{},"Mirrors":[]},"NCPU":4,"MemTotal":2043985920,"GenericResources":null,"DockerRootDir":"/var/home/core/.local/share/containers/storage","HttpProxy":"","HttpsProxy":"","NoProxy":"","Name":"localhost.localdomain","Labels":null,"ExperimentalBuild":true,"ServerVersion":"5.2.3","Runtimes":{"crun":{"path":"/usr/bin/crun"},"crun-vm":{"path":"/usr/bin/crun-vm"},"crun-wasm":{"path":"/usr/bin/crun-wasm"},"kata":{"path":"/usr/bin/kata-runtime"},"krun":{"path":"/usr/bin/krun"},"ocijail":{"path":"/usr/local/bin/ocijail"},"runc":{"path":"/usr/bin/runc"},"runj":{"path":"/usr/local/bin/runj"},"runsc":{"path":"/usr/bin/runsc"},"youki":{"path":"/usr/local/bin/youki"}},"DefaultRuntime":"crun","Swarm":{"NodeID":"","NodeAddr":"","LocalNodeState":"inactive","ControlAvailable":false,"Error":"","RemoteManagers":null},"LiveRestoreEnabled":false,"Isolation":"","InitBinary":"","ContainerdCommit":{"ID":"","Expected":""},"RuncCommit":{"ID":"","Expected":""},"InitCommit":{"ID":"","Expected":""},"SecurityOptions":["name=seccomp,profile=default","name=rootless","name=selinux"],"ProductLicense":"Apache-2.0","CDISpecDirs":null,"Warnings":[],"BuildahVersion":"1.37.3","CPURealtimePeriod":false,"CPURealtimeRuntime":false,"CgroupVersion":"2","Rootless":true,"SwapFree":0,"SwapTotal":0,"Uptime":"29h 17m 36.00s (Approximately 1.21 days)"}
				""")
		]
	}
}
