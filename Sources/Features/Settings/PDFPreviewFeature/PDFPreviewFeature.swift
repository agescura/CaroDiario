import Foundation
import ComposableArchitecture

public struct PDFPreviewFeature: ReducerProtocol {
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
  }
  
  public var body: some ReducerProtocolOf<Self> {
    EmptyReducer()
  }
}
