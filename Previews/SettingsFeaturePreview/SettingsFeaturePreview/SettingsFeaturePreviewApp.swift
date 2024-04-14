import SwiftUI
import ComposableArchitecture
import SettingsFeature
import PasscodeFeature

@main
struct SettingsFeaturePreviewApp: App {
	var body: some Scene {
		WindowGroup {
			SettingsView(
				store: Store(
					initialState: SettingsFeature.State(),
					reducer: { SettingsFeature() }
				)
			)
		}
	}
}
