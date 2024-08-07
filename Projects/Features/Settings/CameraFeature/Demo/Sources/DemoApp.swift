import SwiftUI
import ComposableArchitecture
import CameraFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			CameraView(
				store: Store(
					initialState: CameraFeature.State(),
					reducer: {
						CameraFeature()
					}
				)
			)
		}
	}
}
