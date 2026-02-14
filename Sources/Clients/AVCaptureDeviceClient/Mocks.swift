import Foundation
import Dependencies
import XCTestDynamicOverlay

extension AVCaptureDeviceClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = AVCaptureDeviceClient(
		authorizationStatus: unimplemented("\(Self.self).authorizationStatus", placeholder: .notDetermined),
		requestAccess: unimplemented("\(Self.self).requestAccess", placeholder: false)
  )
}

extension AVCaptureDeviceClient {
  public static let noop = AVCaptureDeviceClient(
    authorizationStatus: { .notDetermined },
    requestAccess: { false }
  )
}
