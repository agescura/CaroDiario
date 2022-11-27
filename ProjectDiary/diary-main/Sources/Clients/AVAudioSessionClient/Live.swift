import ComposableArchitecture
import AVFoundation

extension AVAudioSessionClient: DependencyKey {
  public static var liveValue: AVAudioSessionClient { .live }
}

extension AVAudioSessionClient {
    static var live: Self = {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            print("AVAudioSession configuration error: \(error.localizedDescription)")
        }
        
        return Self(
            recordPermission: { session.recordPermission.permission },
            requestRecordPermission: {
                try await withCheckedThrowingContinuation { continuation in
                    session.requestRecordPermission { granted in
                        continuation.resume(with: .success(granted))
                    }
                }
            }
        )
    }()
}
