import Foundation

public enum AuthorizedVideoStatus: String, Equatable, Codable {
	case notDetermined
	case denied
	case authorized
	case restricted
}
