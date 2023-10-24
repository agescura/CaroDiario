import Foundation
import ComposableArchitecture

public struct PDFPreview: Reducer {
  public init() {}
  
  public struct State: Equatable {
    let pdfData: Data
    
    public init(
      pdfData: Data
    ) {
      self.pdfData = pdfData
    }
  }
  
  public enum Action: Equatable {}
  
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}
