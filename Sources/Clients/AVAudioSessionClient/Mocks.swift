import Foundation
import Dependencies
import XCTestDynamicOverlay

extension AVAudioSessionClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    recordPermission: XCTUnimplemented("\(Self.self).recordPermission"),
    requestRecordPermission: XCTUnimplemented("\(Self.self).requestRecordPermission")
  )
}

extension AVAudioSessionClient {
    public static var noop = Self(
        recordPermission: { .notDetermined },
        requestRecordPermission: { false }
    )
}
