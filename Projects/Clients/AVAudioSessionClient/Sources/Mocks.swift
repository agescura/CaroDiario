import Foundation
import Dependencies
import XCTestDynamicOverlay

extension AVAudioSessionClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
		recordPermission: unimplemented("\(Self.self).recordPermission", placeholder: .notDetermined),
		requestRecordPermission: unimplemented("\(Self.self).requestRecordPermission")
  )
}

extension AVAudioSessionClient {
    public static var noop = Self(
        recordPermission: { .notDetermined },
        requestRecordPermission: { false }
    )
}
