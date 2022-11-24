import Foundation
import ComposableArchitecture
import Dependencies
import XCTestDynamicOverlay

extension LocalAuthenticationClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
    determineType: XCTUnimplemented("\(Self.self).determineType"),
    evaluate: XCTUnimplemented("\(Self.self).evaluate")
  )
}

extension LocalAuthenticationClient {
    public static let noop = Self(
        determineType: { .none },
        evaluate: { _ in false }
    )
    
    public static let faceIdSuccess = Self(
        determineType: { .faceId },
        evaluate: { _ in true }
    )
    
    public static let faceIdFailed = Self(
        determineType: { .faceId },
        evaluate: { _ in false }
    )
    
    public static let touchIdSuccess = Self(
        determineType: { .touchId },
        evaluate: { _ in false }
    )
}
