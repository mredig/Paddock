import Foundation
import NIOHTTP1

struct ListSecretsEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [Secret]
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	init() {}
	
	var path: String {
		"secrets"
	}
}
