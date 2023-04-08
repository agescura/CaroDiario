import AVFoundation
import Models
import Dependencies

extension DependencyValues {
  public var avAudioSessionClient: AVAudioSessionClient {
    get { self[AVAudioSessionClient.self] }
    set { self[AVAudioSessionClient.self] = newValue }
  }
}

public struct AVAudioSessionClient {
    public var recordPermission: () -> AudioRecordPermission
    public var requestRecordPermission: () async throws -> Bool
}

extension AVAudioSession.RecordPermission {
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
