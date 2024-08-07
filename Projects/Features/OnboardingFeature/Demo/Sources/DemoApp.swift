import SwiftUI
import ComposableArchitecture
import OnboardingFeature
import XCTestDynamicOverlay
@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			if !_XCTIsTesting {
				WelcomeView(
					store: Store(
						initialState: WelcomeFeature.State(),
						reducer: {
							WelcomeFeature()
						}
					)
				)
			}
		}
	}
}
