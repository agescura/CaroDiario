import AddEntryFeature
import ComposableArchitecture
import Models
import Styles
import SwiftUI

@main
struct AddEntryFeaturePreviewApp: App {
	
	init() {
		registerFonts()
	}
	
	var body: some Scene {
		WindowGroup {
			AddEntryView(
				store: Store(
					initialState: AddEntryFeature.State(
						entry: Entry(
							id: .init(),
							date: .init(),
							startDay: .init(),
							text: .init(id: .init(), message: "", lastUpdated: .init())
						)
					),
					reducer: AddEntryFeature.init
				)
			)
		}
	}
}
