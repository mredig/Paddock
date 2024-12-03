@testable import Paddock

extension InspectContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		switch nameOrId {
		case "ce25040926ba103e72dd4070db9a07c4510291a3a3475b0cb175dd06dddfbc93":
			return [
				.string("""
					{"AppArmorProfile":"","Args":["--option"],"Config":{"AttachStderr":false,"AttachStdin":false,"AttachStdout":false,"Cmd":["/custom/command","--option"],"Domainname":"","Entrypoint":[],"Env":["container=podman","PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"],"ExposedPorts":{"80/tcp":{}},"Hostname":"ce25040926ba","Image":"docker.io/library/hello-world:latest","Labels":{},"OnBuild":null,"OpenStdin":false,"StdinOnce":false,"StopSignal":"15","StopTimeout":10,"Tty":false,"User":"","Volumes":null,"WorkingDir":"/"},"Created":"2024-11-22T08:59:12.398708593Z","Driver":"overlay","ExecIDs":[],"GraphDriver":{"Data":{"LowerDir":"/var/home/core/.local/share/containers/storage/overlay/12660636fe55438cc3ae7424da7ac56e845cdb52493ff9cf949c47a7f57f8b43/diff","UpperDir":"/var/home/core/.local/share/containers/storage/overlay/ed5b652c53438edede43a21342fcb0fbe8756d8989cc3faced8f687b80732904/diff","WorkDir":"/var/home/core/.local/share/containers/storage/overlay/ed5b652c53438edede43a21342fcb0fbe8756d8989cc3faced8f687b80732904/work"},"Name":"overlay"},"HostConfig":{"AutoRemove":false,"Binds":[],"BlkioDeviceReadBps":null,"BlkioDeviceReadIOps":null,"BlkioDeviceWriteBps":null,"BlkioDeviceWriteIOps":null,"BlkioWeight":0,"BlkioWeightDevice":null,"CapAdd":[],"CapDrop":[],"Cgroup":"","CgroupParent":"user.slice","CgroupnsMode":"","ConsoleSize":[0,0],"ContainerIDFile":"","CpuCount":0,"CpuPercent":0,"CpuPeriod":0,"CpuQuota":0,"CpuRealtimePeriod":0,"CpuRealtimeRuntime":0,"CpuShares":0,"CpusetCpus":"","CpusetMems":"","DeviceCgroupRules":null,"DeviceRequests":null,"Devices":[],"Dns":[],"DnsOptions":[],"DnsSearch":[],"ExtraHosts":[],"GroupAdd":[],"IOMaximumBandwidth":0,"IOMaximumIOps":0,"IpcMode":"shareable","Isolation":"","Links":null,"LogConfig":{"Config":null,"Type":"journald"},"MaskedPaths":null,"Memory":67108864,"MemoryReservation":33554432,"MemorySwap":67108864,"MemorySwappiness":-1,"NanoCpus":0,"NetworkMode":"bridge","OomKillDisable":false,"OomScoreAdj":0,"PidMode":"private","PidsLimit":0,"PortBindings":{"80/tcp":[{"HostIp":"0.0.0.0","HostPort":"8008"}]},"Privileged":false,"PublishAllPorts":false,"ReadonlyPaths":null,"ReadonlyRootfs":false,"RestartPolicy":{"MaximumRetryCount":0,"Name":"no"},"Runtime":"oci","SecurityOpt":[],"ShmSize":65536000,"UTSMode":"private","Ulimits":[],"UsernsMode":"","VolumeDriver":"","VolumesFrom":null},"HostnamePath":"","HostsPath":"","Id":"ce25040926ba103e72dd4070db9a07c4510291a3a3475b0cb175dd06dddfbc93","Image":"sha256:ee301c921b8aadc002973b2e0c3da17d701dcd994b606769a7e6eaa100b81d44","LogPath":"","MountLabel":"system_u:object_r:container_file_t:s0:c147,c152","Mounts":[],"Name":"/81A5DB11-78E9-4B21-9943-23FB75818224","NetworkSettings":{"Bridge":"","EndpointID":"","Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"HairpinMode":false,"IPAddress":"","IPPrefixLen":0,"IPv6Gateway":"","LinkLocalIPv6Address":"","LinkLocalIPv6PrefixLen":0,"MacAddress":"","Networks":{"podman":{"Aliases":["ce25040926ba"],"DNSNames":null,"DriverOpts":null,"EndpointID":"","Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"IPAMConfig":null,"IPAddress":"","IPPrefixLen":0,"IPv6Gateway":"","Links":null,"MacAddress":"","NetworkID":"podman"}},"Ports":{},"SandboxID":"","SandboxKey":"","SecondaryIPAddresses":null,"SecondaryIPv6Addresses":null},"Path":"/hello","Platform":"linux","ProcessLabel":"system_u:system_r:container_t:s0:c147,c152","ResolvConfPath":"","RestartCount":0,"SizeRootFs":0,"State":{"Dead":false,"Error":"","ExitCode":0,"FinishedAt":"0001-01-01T00:00:00Z","OOMKilled":false,"Paused":false,"Pid":0,"Restarting":false,"Running":false,"StartedAt":"0001-01-01T00:00:00Z","Status":"created"}}
					""")
			]
		case "7eb61d5ac2202df115c7ef2875732b800d7e20c1e7e53e7eb470afa2b98bfd72":
			return [
				.string(#"{"Id":"7eb61d5ac2202df115c7ef2875732b800d7e20c1e7e53e7eb470afa2b98bfd72","Created":"2024-11-25T08:41:33.6583148Z","Path":"/usr/local/bin/podman_hello_world","Args":["/hello"],"State":{"Status":"created","Running":false,"Paused":false,"Restarting":false,"OOMKilled":false,"Dead":false,"Pid":0,"ExitCode":0,"Error":"","StartedAt":"0001-01-01T00:00:00Z","FinishedAt":"0001-01-01T00:00:00Z"},"Image":"sha256:83fc7ce1224f5ed3885f6aaec0bb001c0bbb2a308e3250d7408804a720c72a32","ResolvConfPath":"","HostnamePath":"","HostsPath":"","LogPath":"","Name":"/amazing_roentgen","RestartCount":0,"Driver":"overlay","Platform":"linux","MountLabel":"system_u:object_r:container_file_t:s0:c255,c738","ProcessLabel":"system_u:system_r:container_t:s0:c255,c738","AppArmorProfile":"","ExecIDs":[],"HostConfig":{"Binds":[],"ContainerIDFile":"","LogConfig":{"Type":"journald","Config":null},"NetworkMode":"bridge","PortBindings":{},"RestartPolicy":{"Name":"no","MaximumRetryCount":0},"AutoRemove":false,"VolumeDriver":"","VolumesFrom":null,"ConsoleSize":[0,0],"CapAdd":[],"CapDrop":["CHOWN","DAC_OVERRIDE","FOWNER","FSETID","KILL","NET_BIND_SERVICE","SETFCAP","SETGID","SETPCAP","SETUID"],"CgroupnsMode":"","Dns":[],"DnsOptions":[],"DnsSearch":[],"ExtraHosts":[],"GroupAdd":[],"IpcMode":"shareable","Cgroup":"","Links":null,"OomScoreAdj":0,"PidMode":"private","Privileged":false,"PublishAllPorts":false,"ReadonlyRootfs":false,"SecurityOpt":[],"UTSMode":"private","UsernsMode":"","ShmSize":65536000,"Runtime":"oci","Isolation":"","CpuShares":0,"Memory":0,"NanoCpus":0,"CgroupParent":"user.slice","BlkioWeight":0,"BlkioWeightDevice":null,"BlkioDeviceReadBps":null,"BlkioDeviceWriteBps":null,"BlkioDeviceReadIOps":null,"BlkioDeviceWriteIOps":null,"CpuPeriod":0,"CpuQuota":0,"CpuRealtimePeriod":0,"CpuRealtimeRuntime":0,"CpusetCpus":"","CpusetMems":"","Devices":[],"DeviceCgroupRules":null,"DeviceRequests":null,"MemoryReservation":0,"MemorySwap":0,"MemorySwappiness":0,"OomKillDisable":false,"PidsLimit":0,"Ulimits":[],"CpuCount":0,"CpuPercent":0,"IOMaximumIOps":0,"IOMaximumBandwidth":0,"MaskedPaths":null,"ReadonlyPaths":null},"GraphDriver":{"Data":{"LowerDir":"/var/home/core/.local/share/containers/storage/overlay/55f6d36790cbd258a2173e1599268519414f9973696bcfc0f5193c1accee0951/diff","UpperDir":"/var/home/core/.local/share/containers/storage/overlay/77ee2decf083b2d06212775ddde9322e356cb66fd394c3ea962271f9ec2f1f4a/diff","WorkDir":"/var/home/core/.local/share/containers/storage/overlay/77ee2decf083b2d06212775ddde9322e356cb66fd394c3ea962271f9ec2f1f4a/work"},"Name":"overlay"},"SizeRootFs":0,"Mounts":[],"Config":{"Hostname":"7eb61d5ac220","Domainname":"","User":"","AttachStdin":false,"AttachStdout":false,"AttachStderr":false,"Tty":false,"OpenStdin":false,"StdinOnce":false,"Env":["container=podman","PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"],"Cmd":["/hello"],"Image":"quay.io/podman/hello:latest","Volumes":null,"WorkingDir":"/","Entrypoint":[],"OnBuild":null,"Labels":{"artist":"Máirín Ní Ḋuḃṫaiġ, X/Twitter:@mairin","io.buildah.version":"1.23.1","io.containers.capabilities":"sys_chroot","maintainer":"Podman Maintainers","org.opencontainers.image.description":"Hello world image with ascii art","org.opencontainers.image.documentation":"https://github.com/containers/PodmanHello/blob/76b262056eae09851d0a952d0f42b5bbeedde471/README.md","org.opencontainers.image.revision":"76b262056eae09851d0a952d0f42b5bbeedde471","org.opencontainers.image.source":"https://raw.githubusercontent.com/containers/PodmanHello/76b262056eae09851d0a952d0f42b5bbeedde471/Containerfile","org.opencontainers.image.title":"hello image","org.opencontainers.image.url":"https://github.com/containers/PodmanHello/actions/runs/9239934617"},"StopSignal":"15","StopTimeout":10},"NetworkSettings":{"Bridge":"","SandboxID":"","SandboxKey":"","Ports":{},"HairpinMode":false,"LinkLocalIPv6Address":"","LinkLocalIPv6PrefixLen":0,"SecondaryIPAddresses":null,"SecondaryIPv6Addresses":null,"EndpointID":"","Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"IPAddress":"","IPPrefixLen":0,"IPv6Gateway":"","MacAddress":"","Networks":{"podman":{"IPAMConfig":null,"Links":null,"Aliases":["7eb61d5ac220"],"MacAddress":"","DriverOpts":null,"NetworkID":"podman","EndpointID":"","Gateway":"","IPAddress":"","IPPrefixLen":0,"IPv6Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"DNSNames":null}}}}"#)
			]
		default:
			logger.debug("Unrecognized container requested: \(nameOrId)")
			return []
		}
	}
}