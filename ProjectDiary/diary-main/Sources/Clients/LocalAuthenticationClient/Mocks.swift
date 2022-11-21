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
        determineType: { Effect(value: .none) },
        evaluate: { _ in .fireAndForget {} }
    )
    
    public static let faceIdSuccess = Self(
        determineType: {
            Effect(value: .faceId)
        },
        evaluate: { _ in
            Effect(value: true)
        }
    )
    
    public static let faceIdFailed = Self(
        determineType: {
            Effect(value: .faceId)
        },
        evaluate: { _ in
            Effect(value: true)
        }
    )
    
    public static let touchIdSuccess = Self(
        determineType: {
            Effect(value: .touchId)
        },
        evaluate: { _ in
            Effect(value: false)
        }
    )
}
