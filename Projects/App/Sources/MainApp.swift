import AppFeature
import ComposableArchitecture
import SwiftUI

@main
struct MainApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@Environment(\.scenePhase) var scenePhase
	
	var body: some Scene {
		WindowGroup {
			if !_XCTIsTesting {
				AppView(store: self.appDelegate.store)
					.onOpenURL(perform: self.appDelegate.process)
					.onChange(of: self.scenePhase) { self.appDelegate.update(state: $1) }
			}
		}
	}
}
