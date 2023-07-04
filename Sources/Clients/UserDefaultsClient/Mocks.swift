import Foundation
import Dependencies
import XCTestDynamicOverlay

extension UserDefaultsClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
	 setObject: XCTUnimplemented("\(Self.self).set"),
	 objectForKey: XCTUnimplemented("\(Self.self).objectForKey")
  )
}

extension UserDefaultsClient {
  public static let noop = Self(
	 setObject: { _, _ in },
	 objectForKey: { _ in nil }
  )
}
