import ComposableArchitecture
import Foundation
import Models

@Reducer
public struct InsertFeature {
  public init() {}
  
	@ObservableState
  public struct State: Equatable {
    public var step: Step = .firstCode
    public var code: String = ""
    public var firstCode: String = ""
    public let maxNumbersCode = 4
    public var codeActivated: Bool = false
    public var codeNotMatched: Bool = false
    
    public var hasPasscode: Bool {
      self.code == self.firstCode && self.code.count == self.maxNumbersCode
    }
    
    public init() {}
    
    public enum Step: Int {
      case firstCode
      case secondCode
      
      var title: String {
        switch self {
        case .firstCode:
          return "Passcode.Insert".localized
        case .secondCode:
          return "Passcode.Reinsert".localized
        }
      }
    }
  }

  public enum Action: Equatable {
    case update(code: String)
    case success
    case popToRoot
  }
  
  public var body: some ReducerOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action> {
    switch action {
    case let .update(code: code):
      state.code = code
      if state.step == .firstCode,
         state.code.count == state.maxNumbersCode {
        state.codeNotMatched = false
        state.firstCode = state.code
        state.step = .secondCode
        state.code = ""
      }
      if state.step == .secondCode,
         state.code.count == state.maxNumbersCode {
        if state.code == state.firstCode {
//          return .send(.navigateMenu(true))
        } else {
          state.step = .firstCode
          state.code = ""
          state.firstCode = ""
          state.codeNotMatched = true
        }
      }
      return .none
      
    case .success:
      return .none
      
    case .popToRoot:
      return .none
    }
  }
}
