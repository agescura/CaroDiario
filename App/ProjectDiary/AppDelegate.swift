import SwiftUI
import ComposableArchitecture
import RootFeature
import Styles
import SplashFeature

class AppDelegate: NSObject, UIApplicationDelegate {
  let store: StoreOf<RootFeature>
  
  lazy var viewStore = ViewStore(
    store.stateless
  )
  
  override init() {
    self.store = Store(
		initialState: RootFeature.State(
        appDelegate: AppDelegateState(),
		  feature: .splash(SplashFeature.State())
      ),
		reducer: RootFeature()
	 )
  }
  
  func application(
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
  
  func process(url: URL) {
    viewStore.send(.process(url))
  }
  
  func update(state: ScenePhase) {
    viewStore.send(.state(state.value))
  }
  
  func application(
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
