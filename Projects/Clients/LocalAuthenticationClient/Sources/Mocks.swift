import Foundation
import Dependencies
import XCTestDynamicOverlay

extension LocalAuthenticationClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
		determineType: unimplemented("\(Self.self).determineType", placeholder: .none),
		evaluate: unimplemented("\(Self.self).evaluate", placeholder: false)
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
