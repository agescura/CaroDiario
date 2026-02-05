import Foundation
import Dependencies
import XCTestDynamicOverlay

extension AVAudioSessionClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = AVAudioSessionClient(
		recordPermission: unimplemented("\(Self.self).recordPermission", placeholder: .notDetermined),
		requestRecordPermission: unimplemented("\(Self.self).requestRecordPermission")
  )
}

extension AVAudioSessionClient {
    public static let noop = AVAudioSessionClient(
        recordPermission: { .notDetermined },
        requestRecordPermission: { false }
    )
}
