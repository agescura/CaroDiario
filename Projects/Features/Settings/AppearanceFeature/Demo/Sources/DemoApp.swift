import SwiftUI
import ComposableArchitecture
import AppearanceFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			AppearanceView(
				store: Store(
					initialState: AppearanceFeature.State(),
					reducer: {
						AppearanceFeature()
					}
				)
			)
		}
	}
}
