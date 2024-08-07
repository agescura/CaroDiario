import SwiftUI
import ComposableArchitecture
import AgreementsFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			AgreementsView(
				store: Store(
					initialState: AgreementsFeature.State(),
					reducer: {
						AgreementsFeature()
					}
				)
			)
		}
	}
}
