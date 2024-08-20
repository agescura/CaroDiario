import Foundation
import Dependencies
import XCTestDynamicOverlay

extension UserDefaultsClient: TestDependencyKey {
  public static let previewValue = Self.noop
  
  public static let testValue = Self(
		boolForKey: unimplemented("\(Self.self).boolForKey", placeholder: false),
		setBool: unimplemented("\(Self.self).setBool"),
		stringForKey: unimplemented("\(Self.self).stringForKey", placeholder: ""),
		setString: unimplemented("\(Self.self).setString"),
		intForKey: unimplemented("\(Self.self).intForKey", placeholder: 0),
		setInt: unimplemented("\(Self.self).setInt"),
		dateForKey: unimplemented("\(Self.self).dateForKey", placeholder: Date()),
		setDate: unimplemented("\(Self.self).setDate"),
		remove: unimplemented("\(Self.self).remove")
  )
}

extension UserDefaultsClient {
  public static let noop = Self(
    boolForKey: { _ in false },
    setBool: { _, _ in },
    stringForKey: { _ in nil },
    setString: { _, _ in },
    intForKey: { _ in nil },
    setInt: { _, _ in },
    dateForKey: { _ in nil },
    setDate: { _, _ in },
    remove: { _ in }
  )
}
