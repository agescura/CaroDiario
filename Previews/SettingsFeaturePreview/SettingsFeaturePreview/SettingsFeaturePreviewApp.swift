import SwiftUI
import ComposableArchitecture
import SettingsFeature

@main
struct SettingsFeaturePreviewApp: App {
	var body: some Scene {
		WindowGroup {
			NavigationView {
				SettingsView(
					store: .init(
						initialState: SettingsFeature.State(
							styleType: .rectangle,
							layoutType: .horizontal,
							themeType: .dark,
							iconType: .dark,
							hasPasscode: false,
							cameraStatus: .notDetermined,
							optionTimeForAskPasscode: 0,
							faceIdEnabled: false,
							language: .spanish,
							microphoneStatus: .notDetermined
						),
						reducer: SettingsFeature()
							._printChanges()
					)
				)
			}
		}
	}
}
