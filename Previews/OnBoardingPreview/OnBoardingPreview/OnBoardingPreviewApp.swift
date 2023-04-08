import SwiftUI
import ComposableArchitecture
import OnboardingFeature

@main
struct OnBoardingPreviewApp: App {
  var body: some Scene {
    WindowGroup {
      WelcomeView(
        store: .init(
          initialState: .init(),
          reducer: WelcomeFeature()
        )
      )
    }
  }
}
