import Foundation

public enum AudioRecordPermission: Codable, Sendable {
    case authorized
    case denied
    case notDetermined
}
