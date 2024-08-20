import Foundation
import Dependencies
import XCTestDynamicOverlay

extension AVCaptureDeviceClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
		authorizationStatus: unimplemented("\(Self.self).authorizationStatus", placeholder: .notDetermined),
		requestAccess: unimplemented("\(Self.self).requestAccess", placeholder: false)
  )
}

extension AVCaptureDeviceClient {
  public static let noop = Self(
    authorizationStatus: { .notDetermined },
    requestAccess: { false }
  )
}
