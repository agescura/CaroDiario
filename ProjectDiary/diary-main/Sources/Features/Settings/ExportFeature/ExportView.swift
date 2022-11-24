import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import PDFPreviewFeature
import Models

public struct ExportView: View {
  let store: StoreOf<Export>
  
  public init(
    store: StoreOf<Export>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Form {
        Section() {
          HStack(spacing: 16) {
            IconImageView(
              .docTextMagnifyingglass,
              foregroundColor: .berryRed
            )
            
            Text("PDF.Preview".localized)
              .foregroundColor(.chambray)
              .adaptiveFont(.latoRegular, size: 12)
            Spacer()
            Image(.infoCircle)
              .foregroundColor(.blue)
          }
          .contentShape(Rectangle())
          .onTapGesture { viewStore.send(.previewPDF) }
        }
        
        Section() {
          HStack(spacing: 16) {
            IconImageView(
              .squareAndArrowUp,
              foregroundColor: .green
            )
            
            Text("PDF.Share".localized)
              .foregroundColor(.chambray)
              .adaptiveFont(.latoRegular, size: 12)
            Spacer()
            Image(.infoCircle)
              .foregroundColor(.blue)
          }
          .contentShape(Rectangle())
          .onTapGesture {
            viewStore.send(.processPDF)
          }
        }
      }
      .fullScreenCover(
        isPresented: viewStore.binding(
          get: \.presentPreview,
          send: Export.Action.presentPDFPreview
        )
      ) {
        IfLetStore(
          store.scope(
            state: \.pdfPreview,
            action: Export.Action.pdfPreview
          ),
          then: PDFPreviewView.init(store:)
        )
      }
    }
    .navigationBarTitle("Settings.ExportPDF".localized)
  }
}
