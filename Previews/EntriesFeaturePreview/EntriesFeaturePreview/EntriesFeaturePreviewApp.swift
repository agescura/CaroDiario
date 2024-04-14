import ComposableArchitecture
import EntriesFeature
import Models
import SwiftUI

@main
struct EntriesFeaturePreviewApp: App {
	var body: some Scene {
		WindowGroup {
			EntriesView(
				store: Store(
					initialState: EntriesFeature.State(),
					reducer: { EntriesFeature() }
				) {
					$0.coreDataClient.subscriber = {
						AsyncStream { continuation in
							continuation.yield(
								[
									[
										Entry(id: UUID(), date: Date(), startDay: Date(), text: EntryText(id: UUID(), message: "HELLO", lastUpdated: Date()))
									]
								]
							)
							continuation.finish()
						}
					}
				}
			)
		}
	}
}
