import SwiftUI
import ComposableArchitecture
import AboutFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			AboutView(
				store: Store(
					initialState: AboutFeature.State(),
					reducer: {
						AboutFeature()
					}
				)
			)
		}
	}
}
