import ComposableArchitecture
import UIKit
import Dependencies

extension DependencyValues {
  public var applicationClient: UIApplicationClient {
    get { self[UIApplicationClient.self] }
    set { self[UIApplicationClient.self] = newValue }
  }
}

public struct UIApplicationClient {
    public let alternateIconName: String?
    public var setAlternateIconName: (String?) async throws -> Void
    public let supportsAlternateIcons: () -> Bool
    public let openSettings: () -> Effect<Never, Never>
    public var open: @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Void
    public var canOpen: (URL) -> Bool
    public let share: (Any, UIApplicationClient.PopoverPosition) -> Effect<Never, Never>
    public let showTabView: (Bool) -> Effect<Never, Never>
    
    public enum PopoverPosition {
        case text
        case attachment
        case pdf
    }
    
    public init(
        alternateIconName: String?,
        setAlternateIconName: @escaping (String?) async throws -> Void,
        supportsAlternateIcons: @escaping () -> Bool,
        openSettings: @escaping () -> Effect<Never, Never>,
        open: @escaping @Sendable (URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Void,
        canOpen: @escaping (URL) -> Bool,
        share: @escaping (Any, UIApplicationClient.PopoverPosition) -> Effect<Never, Never>,
        showTabView: @escaping (Bool) -> Effect<Never, Never>
    ) {
        self.alternateIconName = alternateIconName
        self.setAlternateIconName = setAlternateIconName
        self.supportsAlternateIcons = supportsAlternateIcons
        self.openSettings = openSettings
        self.open = open
        self.canOpen = canOpen
        self.share = share
        self.showTabView = showTabView
    }
}
