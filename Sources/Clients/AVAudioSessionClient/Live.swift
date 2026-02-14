import Dependencies
import AVFoundation

extension AVAudioSessionClient: DependencyKey {
  public static var liveValue: AVAudioSessionClient { .live }
}

extension AVAudioSessionClient {
    public static var live: Self {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            print("AVAudioSession configuration error: \(error.localizedDescription)")
        }
        
        return AVAudioSessionClient(
					recordPermission: { AVAudioApplication.shared.recordPermission.permission },
            requestRecordPermission: {
                try await withCheckedThrowingContinuation { continuation in
									AVAudioApplication.requestRecordPermission() { granted in
                        continuation.resume(with: .success(granted))
                    }
                }
            }
        )
    }
}
