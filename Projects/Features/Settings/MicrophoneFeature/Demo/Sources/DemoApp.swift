import SwiftUI
import ComposableArchitecture
import MicrophoneFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			MicrophoneView(
				store: Store(
					initialState: MicrophoneFeature.State(),
					reducer: {
						MicrophoneFeature()
					}
				)
			)
		}
	}
}
