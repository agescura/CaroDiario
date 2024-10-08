import SwiftUI
import ComposableArchitecture

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
		@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
		
		func scene(
				_ scene: UIScene,
				willConnectTo session: UISceneSession,
				options connectionOptions: UIScene.ConnectionOptions
		) {
				appDelegate.store.send(.appDelegate(.didFinishLaunching))
		}
		
		func windowScene(
				_ windowScene: UIWindowScene,
				performActionFor shortcutItem: UIApplicationShortcutItem,
				completionHandler: @escaping (Bool) -> Void
		) {
				appDelegate.store.send(.shortcuts)
				completionHandler(true)
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
