import Foundation
import Dependencies
import XCTestDynamicOverlay

extension UIApplicationClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
		alternateIconName: unimplemented("\(Self.self).alternateIconName"),
		setAlternateIconName: unimplemented("\(Self.self).setAlternateIconName"),
		supportsAlternateIcons: unimplemented("\(Self.self).supportsAlternateIcons"),
		openSettings: unimplemented("\(Self.self).openSettings"),
		open: unimplemented("\(Self.self).open"),
		canOpen: unimplemented("\(Self.self).canOpen"),
		share: unimplemented("\(Self.self).share"),
		showTabView: unimplemented("\(Self.self).showTabView"),
		setUserInterfaceStyle: unimplemented("\(Self.self).setUserInterfaceStyle")
  )
}

extension UIApplicationClient {
  public static let noop = Self(
    alternateIconName: { nil },
    setAlternateIconName: { _ in () },
    supportsAlternateIcons: { true },
    openSettings: { },
    open: { _, _ in },
    canOpen: { _ in true },
    share: { _, _ in },
    showTabView: { _ in },
    setUserInterfaceStyle: { _ in }
  )
}
