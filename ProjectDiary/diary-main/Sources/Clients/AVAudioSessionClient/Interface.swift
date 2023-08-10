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
    
    public init(
        recordPermission: @escaping () -> AudioRecordPermission,
        requestRecordPermission: @escaping () async throws -> Bool
    ) {
        self.recordPermission = recordPermission
        self.requestRecordPermission = requestRecordPermission
    }
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
