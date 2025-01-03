import Foundation
import NIOHTTP1

struct InspectVolumeEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = Volume
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	private let nameOrId: String
	
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}
	
	var path: String {
		"volumes/\(nameOrId)"
	}
}
