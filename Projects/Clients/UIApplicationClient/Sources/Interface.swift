import UIKit
import Dependencies

extension DependencyValues {
  public var applicationClient: UIApplicationClient {
    get { self[UIApplicationClient.self] }
    set { self[UIApplicationClient.self] = newValue }
  }
}

public struct UIApplicationClient {
  public let alternateIconName: () -> String?
  public var setAlternateIconName: (String?) async throws -> Void
  public let supportsAlternateIcons: () -> Bool
  public var openSettings: @Sendable () async -> Void
  public var open: @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Void
  public var canOpen: (URL) -> Bool
  public let share: (Any, UIApplicationClient.PopoverPosition) -> Void
  public let showTabView: (Bool) -> Void
  public var setUserInterfaceStyle: @Sendable (UIUserInterfaceStyle) async -> Void
  
  public enum PopoverPosition {
    case text
    case attachment
    case pdf
  }
  
  public init(
    alternateIconName: @escaping () -> String?,
    setAlternateIconName: @escaping (String?) async throws -> Void,
    supportsAlternateIcons: @escaping () -> Bool,
    openSettings: @escaping @Sendable () async -> Void,
    open: @escaping @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Void,
    canOpen: @escaping (URL) -> Bool,
    share: @escaping (Any, UIApplicationClient.PopoverPosition) -> Void,
    showTabView: @escaping (Bool) -> Void,
    setUserInterfaceStyle: @escaping @Sendable (UIUserInterfaceStyle) async -> Void
  ) {
    self.alternateIconName = alternateIconName
    self.setAlternateIconName = setAlternateIconName
    self.supportsAlternateIcons = supportsAlternateIcons
    self.openSettings = openSettings
    self.open = open
    self.canOpen = canOpen
    self.share = share
    self.showTabView = showTabView
    self.setUserInterfaceStyle = setUserInterfaceStyle
  }
}
