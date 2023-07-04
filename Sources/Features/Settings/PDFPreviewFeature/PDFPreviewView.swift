import ComposableArchitecture
import SwiftUI
import Views

public struct PDFPreviewView: View {
  let store: StoreOf<PDFPreviewFeature>
  
  public init(
    store: StoreOf<PDFPreviewFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(
		self.store.actionless,
		observe: \.pdfData
	 ) { viewStore in
		 PDFViewRepresentable(data: viewStore.state)
			.edgesIgnoringSafeArea(.all)
    }
  }
}
