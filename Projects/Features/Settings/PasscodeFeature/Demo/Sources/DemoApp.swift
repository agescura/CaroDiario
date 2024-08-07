import SwiftUI
import ComposableArchitecture
import PasscodeFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			MenuPasscodeView(
				store: Store(
					initialState: MenuFeature.State(),
					reducer: {
						MenuFeature()
					}
				)
			)
		}
	}
}
