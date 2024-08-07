import SwiftUI
import ComposableArchitecture
import PDFPreviewFeature

@main
struct DemoApp: App {
	var body: some Scene {
		WindowGroup {
			PDFPreviewView(
				store: Store(
					initialState: PDFPreviewFeature.State(pdfData: Data()),
					reducer: {
						PDFPreviewFeature()
					}
				)
			)
		}
	}
}
