import SwiftUI
import LanguageFeature
import ComposableArchitecture

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			LanguageView(
				store: Store(
					initialState: LanguageFeature.State(),
					reducer: {
						LanguageFeature()
					}
				)
			)
		}
	}
}
