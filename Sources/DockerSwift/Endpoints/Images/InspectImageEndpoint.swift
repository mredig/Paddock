import Foundation
import NIOHTTP1
import Logging

struct InspectImagesEndpoint: SimpleEndpoint {
    typealias Body = NoBody
    typealias Response = Image
    var method: HTTPMethod = .GET

    let logger: Logger

    let nameOrId: String
    
    init(nameOrId: String, logger: Logger) {
        self.nameOrId = nameOrId
        self.logger = logger
    }
    
    var path: String {
        "images/\(nameOrId)/json"
    }
}

extension InspectImagesEndpoint: MockedResponseEndpoint {
    var responseData: [MockedResponseData] {
        switch nameOrId {
        case "hello-world:latest":
            return [
                .string("""
                    {"Id":"sha256:ee301c921b8aadc002973b2e0c3da17d701dcd994b606769a7e6eaa100b81d44","RepoTags":["docker.io/library/hello-world:latest"],"RepoDigests":["docker.io/library/hello-world@sha256:2d4e459f4ecb5329407ae3e47cbc107a2fbace221354ca75960af4c047b3cb13","docker.io/library/hello-world@sha256:305243c734571da2d100c8c8b3c3167a098cab6049c9a5b066b6021a60fcb966"],"Parent":"","Comment":"buildkit.dockerfile.v0","Created":"2023-05-02T16:49:27Z","ContainerConfig":{"Hostname":"ee301c921b8","Domainname":"","User":"","AttachStdin":false,"AttachStdout":false,"AttachStderr":false,"Tty":false,"OpenStdin":false,"StdinOnce":false,"Env":null,"Cmd":null,"Image":"","Volumes":null,"WorkingDir":"","Entrypoint":null,"OnBuild":null,"Labels":null},"DockerVersion":"","Author":"","Config":{"Hostname":"","Domainname":"","User":"","AttachStdin":false,"AttachStdout":false,"AttachStderr":false,"Tty":false,"OpenStdin":false,"StdinOnce":false,"Env":["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"],"Cmd":["/hello"],"Image":"","Volumes":null,"WorkingDir":"/","Entrypoint":null,"OnBuild":null,"Labels":null},"Architecture":"arm64","Os":"linux","Size":24446,"VirtualSize":24446,"GraphDriver":{"Data":{"UpperDir":"/var/home/core/.local/share/containers/storage/overlay/12660636fe55438cc3ae7424da7ac56e845cdb52493ff9cf949c47a7f57f8b43/diff","WorkDir":"/var/home/core/.local/share/containers/storage/overlay/12660636fe55438cc3ae7424da7ac56e845cdb52493ff9cf949c47a7f57f8b43/work"},"Name":"overlay"},"RootFS":{"Type":"layers","Layers":["sha256:12660636fe55438cc3ae7424da7ac56e845cdb52493ff9cf949c47a7f57f8b43"]},"Metadata":{"LastTagTime":"0001-01-01T00:00:00Z"},"Container":""}
                    """)
            ]
        case "nginx:latest":
            return [
                .string(#"{"Id":"sha256:7a3f95c078122f959979fac556ae6f43746c9f32e5a66526bb503ed1d4adbd07","RepoTags":["docker.io/library/nginx:latest"],"RepoDigests":["docker.io/library/nginx@sha256:bc5eac5eafc581aeda3008b4b1f07ebba230de2f27d47767129a6a905c84f470","docker.io/library/nginx@sha256:bf59355a6d8a42552f258c9ef7327e077309667bbb4d7a410ab891dea95bc3ba"],"Parent":"","Comment":"buildkit.dockerfile.v0","Created":"2024-10-02T17:55:35Z","ContainerConfig":{"Hostname":"7a3f95c0781","Domainname":"","User":"","AttachStdin":false,"AttachStdout":false,"AttachStderr":false,"Tty":false,"OpenStdin":false,"StdinOnce":false,"Env":null,"Cmd":null,"Image":"","Volumes":null,"WorkingDir":"","Entrypoint":null,"OnBuild":null,"Labels":null},"DockerVersion":"","Author":"","Config":{"Hostname":"","Domainname":"","User":"","AttachStdin":false,"AttachStdout":false,"AttachStderr":false,"ExposedPorts":{"80/tcp":{}},"Tty":false,"OpenStdin":false,"StdinOnce":false,"Env":["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin","NGINX_VERSION=1.27.2","NJS_VERSION=0.8.6","NJS_RELEASE=1~bookworm","PKG_RELEASE=1~bookworm","DYNPKG_RELEASE=1~bookworm"],"Cmd":["nginx","-g","daemon off;"],"Image":"","Volumes":null,"WorkingDir":"/","Entrypoint":["/docker-entrypoint.sh"],"OnBuild":null,"Labels":{"maintainer":"NGINX Docker Maintainers \u003cdocker-maint@nginx.com\u003e"},"StopSignal":"SIGQUIT"},"Architecture":"arm64","Os":"linux","Size":200984620,"VirtualSize":200984620,"GraphDriver":{"Data":{"LowerDir":"/var/home/core/.local/share/containers/storage/overlay/710898076ec18b6d1ea57487dd6efc6e477c5ee4469ec88e9ebc8f2c83929992/diff:/var/home/core/.local/share/containers/storage/overlay/08893c7aaae07b423db770053ac2f775ce6f712061c54a6cf5c25f79bcf0f5d9/diff:/var/home/core/.local/share/containers/storage/overlay/facabd0f004ded79e24514a880bd417682bda919751728363f2a791a19418744/diff:/var/home/core/.local/share/containers/storage/overlay/98eac9d451653c0f23406fc61c392912ff9ff3803873897f859a30324b985d12/diff:/var/home/core/.local/share/containers/storage/overlay/436534b4f1de7e258ada4dedc2e418344f4d4340ddcf8b041774dd4681218480/diff:/var/home/core/.local/share/containers/storage/overlay/077584c0c75a9ed7e709ddf807892e87202ffaed0c3ada73e3ca853b425dc067/diff","UpperDir":"/var/home/core/.local/share/containers/storage/overlay/afc8d0a51fad8000fe26e234f8449a326e00d545dc86b54ffdd00954ea26bc32/diff","WorkDir":"/var/home/core/.local/share/containers/storage/overlay/afc8d0a51fad8000fe26e234f8449a326e00d545dc86b54ffdd00954ea26bc32/work"},"Name":"overlay"},"RootFS":{"Type":"layers","Layers":["sha256:077584c0c75a9ed7e709ddf807892e87202ffaed0c3ada73e3ca853b425dc067","sha256:bfbe9ce3ca6c2aab35df9871594c528660e5b3fcc401d358437ad2d45f7f57c4","sha256:a36befd861e7a1f84f9da2d7a44abd774e912c095cba371cfc461698d29f2102","sha256:3a3d1577affcf0a3f0896b00bbb49acd86c529a3ed75c00b636de622a2a4ecbb","sha256:3c517c6e21457587997190703c93f97d45dd3042dcf36727ffff794129631a32","sha256:b2060ef4379533302d8a7acff71c28f6aaaa787740d3da8cfa7463f4bc678e2b","sha256:28adadbd355b83b17b64f7ff7c4f0228996384b2566e4204a9975b62e065ab61"]},"Metadata":{"LastTagTime":"0001-01-01T00:00:00Z"},"Container":""}"#)
            ]
        default:
            logger.error("Requested image not found: \(nameOrId).")
            return []
        }
    }
}
