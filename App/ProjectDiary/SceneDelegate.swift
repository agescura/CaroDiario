import SwiftUI
import ComposableArchitecture
import RootFeature

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        appDelegate.viewStore.send(.appDelegate(.didFinishLaunching))
    }
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        appDelegate.viewStore.send(.shortcuts)
        completionHandler(true)
    }
}

extension ScenePhase {
  var value: RootFeature.State.Status {
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
