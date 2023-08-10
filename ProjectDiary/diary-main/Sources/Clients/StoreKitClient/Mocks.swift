import Foundation
import Dependencies
import XCTestDynamicOverlay

extension StoreKitClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
    requestReview: XCTUnimplemented("\(Self.self).requestReview")
  )
}

extension StoreKitClient {
  public static let noop = Self(
    requestReview: { }
  )
}
