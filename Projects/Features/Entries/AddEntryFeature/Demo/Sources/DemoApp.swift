import SwiftUI
import ComposableArchitecture
import AddEntryFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			NavigationStack {
				AddEntryView(
					store: Store(
						initialState: AddEntryFeature.State(entry: .mock),
						reducer: { AddEntryFeature() }
					)
				)
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						Text("AddEntry.Title".localized)
							.adaptiveFont(.latoBold, size: 16)
							.foregroundColor(.adaptiveBlack)
					}
					ToolbarItem(placement: .confirmationAction) {
						Button {
						} label: {
							Image(.xmark)
								.foregroundColor(.adaptiveBlack)
						}
					}
				}
			}
		}
	}
}
