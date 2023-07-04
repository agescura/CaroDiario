import SwiftUI
import ComposableArchitecture
import SettingsFeature

@main
struct SettingsFeaturePreviewApp: App {
	var body: some Scene {
		WindowGroup {
			SettingsView(
				store: .init(
					initialState: Settings.State(
						styleType: .rectangle,
						layoutType: .horizontal,
						themeType: .dark,
						iconType: .dark,
						hasPasscode: true,
						cameraStatus: .notDetermined,
						optionTimeForAskPasscode: 0,
						faceIdEnabled: false,
						language: .spanish,
						microphoneStatus: .authorized
					),
					reducer: Settings()
				)
			)
		}
	}
}
