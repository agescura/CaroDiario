import ComposableArchitecture
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    appDelegate.store.send(.appDelegate(.didFinishLaunching))
    
    if let shortcutItem = connectionOptions.shortcutItem {
      
    }
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
}

extension UIApplicationShortcutItem {
  var shortcut: AppFeature.Action.Shortcut? {
    switch self.type {
    case "AddAction":
      return .add
    case "SettingsAction":
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
