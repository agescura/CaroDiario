import ComposableArchitecture
import SwiftUI
import Views
import Localizables

public struct PDFPreviewView: View {
	let store: StoreOf<PDFPreviewFeature>
	
	public init(
		store: StoreOf<PDFPreviewFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithPerceptionTracking {
			VStack {
				HStack(spacing: 16) {
					Spacer()
					
					Button(action: {
						self.store.send(.dismiss)
					}, label: {
						Image(.xmark)
							.resizable()
							.frame(width: 18, height: 18)
							.foregroundColor(.chambray)
					})
				}
				.padding()
				
				PDFViewRepresentable(data: self.store.pdfData)
					.edgesIgnoringSafeArea(.all)
			}
		}
	}
}
