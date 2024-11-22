import NIOHTTP1

struct RemoveSecretEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	var method: HTTPMethod = .DELETE
	
	private let nameOrId: String
	
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}
	
	var path: String {
		"secrets/\(nameOrId)"
	}
}
