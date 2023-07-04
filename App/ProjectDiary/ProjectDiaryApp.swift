import SwiftUI
import ComposableArchitecture
import RootFeature

@main
struct ProjectDiaryApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Environment(\.scenePhase) var scenePhase
  
  var body: some Scene {
    WindowGroup {
		 if ProcessInfo.processInfo.environment["UITesting"] == "true" {
			 EmptyView()
		 } else {
			 RootView(store: self.appDelegate.store)
				.onOpenURL(perform: self.appDelegate.process(url:))
				.onChange(
				  of: self.scenePhase,
				  perform: self.appDelegate.update(state:)
				)
		 }
    }
  }
}

extension UINavigationController {
	 open override func viewWillLayoutSubviews() {
		  super.viewWillLayoutSubviews()
		  self.navigationBar.topItem?.backButtonDisplayMode = .minimal
	 }
}
