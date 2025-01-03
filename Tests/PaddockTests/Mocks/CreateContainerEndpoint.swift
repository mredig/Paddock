@testable import Paddock

extension CreateContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		guard let body else {
			logger.debug("Unexpected lack of container configuration for \(Self.self)")
			return []
		}
		switch (body.image, body.command) {
		case
			("nginx:latest", nil),
			("hello-world:latest", ["/custom/command", "--option"]),
			("sha256:7a3f95c078122f959979fac556ae6f43746c9f32e5a66526bb503ed1d4adbd07", _):
			return [
				.string(#"{"Id":"ce25040926ba103e72dd4070db9a07c4510291a3a3475b0cb175dd06dddfbc93","Warnings":[]}"#)
			]
		case ("hello-world:latest", _):
			return [
				.string(#"{"Id":"7eb61d5ac2202df115c7ef2875732b800d7e20c1e7e53e7eb470afa2b98bfd72","Warnings":[]}"#)
			]
		case ("sha256:511a44083d3a23416fadc62847c45d14c25cbace86e7a72b2b350436978a0450", _):
			return [
				.string(#"{"Id":"5d9b694144be16064d164a5453eb753953f9f68e40bbec8099048965ad4dbe50","Warnings":[]}"#)
			]

		default:
			logger.debug("Unexpected mock request for \(Self.self) - \(body.image) \(body.command as Any)")
			return []
		}

	}
}
