import SwiftUI
import ComposableArchitecture
import SettingsFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			SettingsView(
				store: Store(
					initialState: SettingsFeature.State(),
					reducer: {
						SettingsFeature()
					}
				)
			)
		}
	}
}
