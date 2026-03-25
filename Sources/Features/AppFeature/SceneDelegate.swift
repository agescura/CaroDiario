import ComposableArchitecture
import Models
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    appDelegate.store.send(.appDelegate(.didFinishLaunching(connectionOptions.shortcutItem?.shortcut)))
  }
  
  func windowScene(
    _ windowScene: UIWindowScene,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    if let action = shortcutItem.shortcut {
      appDelegate.store.send(.shortcuts(action))
    }
    completionHandler(true)
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    if userSettings.hasShownOnboarding {
      let application = UIApplication.shared
      application.shortcutItems = ShorcutItem.allCases.map { item -> UIApplicationShortcutItem in
        return UIApplicationShortcutItem(
          type: item.rawValue,
          localizedTitle: item.title,
          localizedSubtitle: item.subtitle,
          icon: UIApplicationShortcutIcon(systemImageName: item.icon)
        )
      }
    }
  }
}

public enum ShorcutItem: String, CaseIterable, Sendable {
  case add
  case settings
  
  var title: String {
    switch self {
    case .add: "Add"
    case .settings: "Settings"
    }
  }
  
  var subtitle: String {
    switch self {
    case .add: "Write an entry"
    case .settings: "Show settings"
    }
  }
  
  var icon: String {
    switch self {
    case .add: "plus"
    case .settings: "gear"
    }
  }
}

extension UIApplicationShortcutItem {
  var shortcut: ShorcutItem? {
    switch self.type {
    case "add":
      return .add
    case "settings":
      return .settings
    default:
      return nil
    }
  }
}

extension ScenePhase {
  var value: AppFeature.State.State {
    switch self {
    case .active:
      return .active
    case .inactive:
      return .inactive
    case .background:
      return .background
    @unknown default:
      return .unknown
    }
  }
}
