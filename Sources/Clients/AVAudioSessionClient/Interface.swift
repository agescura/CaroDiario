import AVFoundation
import Models
import Dependencies
import DependenciesMacros

extension DependencyValues {
  public var avAudioSessionClient: AVAudioSessionClient {
    get { self[AVAudioSessionClient.self] }
    set { self[AVAudioSessionClient.self] = newValue }
  }
}

@DependencyClient
public struct AVAudioSessionClient: Sendable {
    public var recordPermission: @Sendable () async throws -> AudioRecordPermission
    public var requestRecordPermission: @Sendable () async throws -> Bool
}

extension AVAudioApplication.recordPermission {
    public var permission: AudioRecordPermission {
        switch self {
        case .granted:
            return .authorized
        case .denied:
            return .denied
        case .undetermined:
            fallthrough
        @unknown default:
            return .notDetermined
        }
    }
}
