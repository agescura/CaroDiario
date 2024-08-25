import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import Styles
import SplashFeature
import SwiftUI

public struct AppDelegateState: Equatable {
  public init() {}
}

@CasePathable
public enum AppDelegateAction: Equatable {
  case didFinishLaunching
}

public class AppDelegate: NSObject, UIApplicationDelegate {
	public let store: StoreOf<AppFeature>
	
	public override init() {
		self.store = Store(
			initialState: AppFeature.State(),
			reducer: { AppFeature()._printChanges() }
		)
	}
	
	public func application(
		_ application: UIApplication,
		didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
	) -> Bool {
		registerFonts()
		
		guard let latoRegular16 = UIFont(name:"Lato-Regular", size: 16),
					let latoRegular40 = UIFont(name:"Lato-Regular", size: 40) else { return true }
		
		UINavigationBar.appearance().titleTextAttributes = [
			.foregroundColor: UIColor(.chambray),
			.font : latoRegular16
		]
		UINavigationBar.appearance().largeTitleTextAttributes = [
			.foregroundColor: UIColor(.chambray),
			.font : latoRegular40
		]
		return true
	}
	
	public func process(url: URL) {
		self.store.send(.process(url))
	}
	
	public func update(state: ScenePhase) {
		self.store.send(.state(state.value))
	}
	
	public func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions
	) -> UISceneConfiguration {
		let sceneConfiguration = UISceneConfiguration(
			name: "Scene Configuration",
			sessionRole: connectingSceneSession.role
		)
		sceneConfiguration.delegateClass = SceneDelegate.self
		
		return sceneConfiguration
	}
}
