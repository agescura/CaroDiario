import ComposableArchitecture
import SettingsFeature
import SwiftUI
import SwiftUIHelper

@main
struct SettingsFeaturePreviewApp: App {
	var body: some Scene {
		WindowGroup {
			NavigationSwitched {
				SettingsView(
					store: Store(
						initialState: SettingsFeature.State(
							userSettings: .defaultValue
						),
						reducer: SettingsFeature()
							._printChanges()
					)
				)
				.navigationTitle("Settings")
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
