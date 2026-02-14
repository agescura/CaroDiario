import ComposableArchitecture
import Foundation

@Reducer
public struct PDFPreviewFeature {
  public init() {}
  
	@ObservableState
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
  
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}
