import Foundation
import NIO

public enum DockerGeneralError: Error {
	/// Not connected to an Attach/Exec endpoint, or disconnected
	case notconnected
	/// Custom error from the Docker daemon
	case message(String)
	case unknownResponse(String)
	case corruptedData(String)
	case unexpectedResponse(ActualResponse, String)

	public enum ActualResponse {
		case buffer(ByteBuffer)
		case string(String)

		init (_ buffer: ByteBuffer) {
			if let str = buffer.getString(at: 0, length: buffer.readableBytes) {
				self = .string(str)
			} else {
				self = .buffer(buffer)
			}
		}
	}
}

public struct DockerError: Codable, Sendable, Error, Hashable {
	/// Forwarded from error json object
	public let message: String
	/// Forwarded from error json object
	public let cause: String?
	/// Forwarded from error json object
	public let response: Int?


	/// Forwarded from response header
	public internal(set) var responseCode: UInt?
	/// Forwarded from response header
	public internal(set) var responseReasonPhrase: String?
}
