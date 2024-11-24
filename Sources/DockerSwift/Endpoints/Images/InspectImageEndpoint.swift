import Foundation
import NIOHTTP1
import Logging

struct InspectImagesEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = Image
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

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
