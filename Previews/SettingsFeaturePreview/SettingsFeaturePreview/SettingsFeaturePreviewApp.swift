import SwiftUI
import ComposableArchitecture
import SettingsFeature
import PasscodeFeature

@main
struct SettingsFeaturePreviewApp: App {
	var body: some Scene {
		WindowGroup {
			MenuPasscodeView(
				store: Store(
					initialState: MenuFeature.State(
						authenticationType: .faceId,
						optionTimeForAskPasscode: 5,
						faceIdEnabled: true
					),
					reducer: { MenuFeature() }
				)
			)
		}
	}
}
