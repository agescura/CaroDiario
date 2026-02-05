import ComposableArchitecture
import DesignSystem
import Localizables
import SwiftUI

public struct PDFPreviewView: View {
	let store: StoreOf<PDFPreviewFeature>
	
	public init(
		store: StoreOf<PDFPreviewFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		VStack {
			HStack(spacing: 16) {
				Spacer()
				
				Button(action: {
					self.store.send(.dismiss)
				}, label: {
          Image(systemName: .xmark)
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
