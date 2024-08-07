import SwiftUI
import ComposableArchitecture
import ExportFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			ExportView(
				store: Store(
					initialState: ExportFeature.State(),
					reducer: {
						ExportFeature()
					}
				)
			)
		}
	}
}
