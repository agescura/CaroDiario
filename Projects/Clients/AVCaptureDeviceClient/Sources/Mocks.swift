import Foundation
import Dependencies
import XCTestDynamicOverlay

extension AVCaptureDeviceClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
    authorizationStatus: XCTUnimplemented("\(Self.self).authorizationStatus"),
    requestAccess: XCTUnimplemented("\(Self.self).requestAccess")
  )
}

extension AVCaptureDeviceClient {
  public static let noop = Self(
    authorizationStatus: { .notDetermined },
    requestAccess: { false }
  )
}
