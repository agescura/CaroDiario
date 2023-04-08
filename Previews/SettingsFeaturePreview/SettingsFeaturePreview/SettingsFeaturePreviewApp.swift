import SwiftUI
import ComposableArchitecture
import SettingsFeature

@main
struct SettingsFeaturePreviewApp: App {
  var body: some Scene {
    WindowGroup {
      SettingsView(
        store: .init(
          initialState: .init(
            styleType: .rectangle,
            layoutType: .horizontal,
            themeType: .dark,
            iconType: .dark,
            hasPasscode: true,
            cameraStatus: .notDetermined,
            optionTimeForAskPasscode: 0,
            faceIdEnabled: false,
            language: .spanish,
            microphoneStatus: .notDetermined
          ),
          reducer: Settings()
        )
      )
    }
  }
}
