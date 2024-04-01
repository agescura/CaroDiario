import Foundation
import ComposableArchitecture
import PDFPreviewFeature
import UIApplicationClient
import PDFKitClient
import Models

public struct Export: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    var presentPreview = false
    var pdfPreview: PDFPreview.State?
    var pdf = Data()
    
    public init() {}
  }
  
  public enum Action: Equatable {
    case processPDF
    case generatePDF([[Entry]])
    case presentActivityView(Data)
    case previewPDF
    case generatePreview([[Entry]])
    case presentPreviewView(Data)
    case presentPDFPreview(Bool)
    case pdfPreview(PDFPreview.Action)
  }
  
  @Dependency(\.mainRunLoop.now.date) private var now
  @Dependency(\.applicationClient) private var applicationClient
  @Dependency(\.pdfKitClient) private var pdfKitClient
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .ifLet(\.pdfPreview, action: /Action.pdfPreview) {
        PDFPreview()
      }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action> {
    switch action {
    case .processPDF:
      return .none
      
    case let .generatePDF(entries):
      return .run { send in
        await send(.presentActivityView(self.pdfKitClient.generatePDF(entries, self.now)))
      }
      
    case let .presentActivityView(file):
      self.applicationClient.share(file, .pdf)
      return .none
      
    case .previewPDF:
      return .none
      
    case let .generatePreview(entries):
      return .run { send in
        await send(.presentPreviewView(self.pdfKitClient.generatePDF(entries, self.now)))
      }
      
    case let .presentPreviewView(file):
      state.pdf = file
      return Effect(value: .presentPDFPreview(true))
      
    case let .presentPDFPreview(value):
      state.presentPreview = value
      state.pdfPreview = value ? .init(pdfData: state.pdf) : nil
      return .none
      
    case .pdfPreview(.dismiss):
      return Effect(value: .presentPDFPreview(false))
      
    case .pdfPreview:
      return .none
    }
  }
}
