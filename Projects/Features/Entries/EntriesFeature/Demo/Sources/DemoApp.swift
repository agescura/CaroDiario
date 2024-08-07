import SwiftUI
import ComposableArchitecture
import EntriesFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			EntriesView(
				store: Store(
					initialState: EntriesFeature.State(),
					reducer: {
						EntriesFeature()
					}
				)
			)
		}
	}
}
