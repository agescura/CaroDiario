import Foundation
import Dependencies
import XCTestDynamicOverlay

extension StoreKitClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
		requestReview: unimplemented("\(Self.self).requestReview", placeholder: ())
  )
}

extension StoreKitClient {
  public static let noop = Self(
    requestReview: { }
  )
}
