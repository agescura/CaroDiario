import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import UIApplicationClient
import PDFKitClient

public struct PDFPreview: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    let pdfData: Data
    
    public init(
      pdfData: Data
    ) {
      self.pdfData = pdfData
    }
  }
  
  public enum Action: Equatable {
    case dismiss
  }
  
  public var body: some ReducerProtocolOf<Self> {
    EmptyReducer()
  }
}

public struct PDFPreviewView: View {
  let store: StoreOf<PDFPreview>
  
  public init(
    store: StoreOf<PDFPreview>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        HStack(spacing: 16) {
          Spacer()
          
          Button(action: {
            viewStore.send(.dismiss)
          }, label: {
            Image(.xmark)
              .resizable()
              .frame(width: 18, height: 18)
              .foregroundColor(.chambray)
          })
        }
        .padding()
        
        PDFViewRepresentable(data: viewStore.pdfData)
          .edgesIgnoringSafeArea(.all)
      }
    }
  }
}
