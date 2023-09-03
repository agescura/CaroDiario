import SwiftUI
import ComposableArchitecture
import EntriesFeature

@main
struct EntriesFeaturePreviewApp: App {
	var body: some Scene {
		WindowGroup {
			EntriesView(
				store: Store(
					initialState: EntriesFeature.State(entries: []),
					reducer: EntriesFeature.init
				)
			)
		}
	}
}
