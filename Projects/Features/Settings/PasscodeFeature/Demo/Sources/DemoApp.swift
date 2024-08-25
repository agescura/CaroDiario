import SwiftUI
import ComposableArchitecture
import PasscodeFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			NavigationStack {
				ActivateView(
					store: Store(
						initialState: ActivateFeature.State(),
						reducer: {
							ActivateFeature()
						}
					)
				)
			}
		}
	}
}
