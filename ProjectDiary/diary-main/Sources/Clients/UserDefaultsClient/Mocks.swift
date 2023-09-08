import Foundation
import Dependencies
import XCTestDynamicOverlay

extension UserDefaultsClient: TestDependencyKey {
	public static let previewValue = Self.noop
	
	public static let testValue = Self(
		userSettings: XCTUnimplemented("\(Self.self).userSettings"),
		setUserSettings: XCTUnimplemented("\(Self.self).setUserSettings"),
		
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
		userSettings: { .defaultValue },
		setUserSettings: { _ in },
		
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
