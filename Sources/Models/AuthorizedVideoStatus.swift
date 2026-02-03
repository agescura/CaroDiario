import Foundation

public enum AuthorizedVideoStatus: String, Equatable, Codable, Sendable {
	case notDetermined
	case denied
	case authorized
	case restricted
}
