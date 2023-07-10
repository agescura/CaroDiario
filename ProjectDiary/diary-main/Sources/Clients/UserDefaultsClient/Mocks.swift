import Foundation
import Dependencies
import XCTestDynamicOverlay

extension UserDefaultsClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
    boolForKey: XCTUnimplemented("\(Self.self).boolForKey"),
    setBool: XCTUnimplemented("\(Self.self).setBool"),
    stringForKey: XCTUnimplemented("\(Self.self).stringForKey"),
    setString: XCTUnimplemented("\(Self.self).setString"),
    intForKey: XCTUnimplemented("\(Self.self).intForKey"),
    setInt: XCTUnimplemented("\(Self.self).setInt"),
    dateForKey: XCTUnimplemented("\(Self.self).dateForKey"),
    setDate: XCTUnimplemented("\(Self.self).setDate"),
    remove: XCTUnimplemented("\(Self.self).remove")
  )
}

extension UserDefaultsClient {
  public static let noop = Self(
    boolForKey: { _ in false },
    setBool: { _, _ in },
    stringForKey: { _ in nil },
    setString: { _, _ in .none },
    intForKey: { _ in nil },
    setInt: { _, _ in .none },
    dateForKey: { _ in nil },
    setDate: { _, _ in .none },
    remove: { _ in .none }
  )
}
