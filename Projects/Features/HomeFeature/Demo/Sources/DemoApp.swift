import SwiftUI
import ComposableArchitecture
import SplashFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			SplashView(
				store: Store(
					initialState: SplashFeature.State(),
					reducer: {
						SplashFeature()
					}
				)
			)
		}
	}
}
