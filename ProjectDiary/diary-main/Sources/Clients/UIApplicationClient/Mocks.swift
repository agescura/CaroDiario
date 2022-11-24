import Foundation
import Dependencies
import XCTestDynamicOverlay

extension UIApplicationClient: TestDependencyKey {
  public static let previewValue = Self.noop

  public static let testValue = Self(
    alternateIconName: nil,
    setAlternateIconName: XCTUnimplemented("\(Self.self).setAlternateIconName"),
    supportsAlternateIcons: XCTUnimplemented("\(Self.self).supportsAlternateIcons"),
    openSettings: XCTUnimplemented("\(Self.self).openSettings"),
    open: XCTUnimplemented("\(Self.self).open"),
    canOpen: XCTUnimplemented("\(Self.self).canOpen"),
    share: XCTUnimplemented("\(Self.self).share"),
    showTabView: XCTUnimplemented("\(Self.self).showTabView"),
    setUserInterfaceStyle: XCTUnimplemented("\(Self.self).setUserInterfaceStyle")
  )
}

extension UIApplicationClient {
  public static let noop = Self(
    alternateIconName: nil,
    setAlternateIconName: { _ in () },
    supportsAlternateIcons: { true },
    openSettings: { },
    open: { _, _ in },
    canOpen: { _ in true },
    share: { _, _ in .fireAndForget {} },
    showTabView: { _ in .fireAndForget {} },
    setUserInterfaceStyle: { _ in }
  )
}
