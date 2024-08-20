import Foundation
import Dependencies
import XCTestDynamicOverlay

extension AVCaptureDeviceClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
		authorizationStatus: unimplemented("\(Self.self).authorizationStatus"),
		requestAccess: unimplemented("\(Self.self).requestAccess")
  )
}

extension AVCaptureDeviceClient {
  public static let noop = Self(
    authorizationStatus: { .notDetermined },
    requestAccess: { false }
  )
}
