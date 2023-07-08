import ComposableArchitecture
import Localizables
import SwiftUI
import Views

public struct PDFPreviewView: View {
  private let store: StoreOf<PDFPreview>
  
  public init(
    store: StoreOf<PDFPreview>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(
		self.store,
		observe: { $0 }
	 ) { viewStore in
		 PDFViewRepresentable(data: viewStore.pdfData)
			.edgesIgnoringSafeArea(.all)
    }
  }
}
