import ComposableArchitecture
import Foundation
import Models

@Reducer
public struct InsertFeature {
  public init() {}
  
	@ObservableState
  public struct State: Equatable {
    public var code: String = ""
    public var codeActivated: Bool = false
    public var codeNotMatched: Bool = false
		public var firstCode: String = ""
		public let maxNumbersCode = 4
		public var step: Step = .firstCode
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
    
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
		case delegate(Delegate)
		case popButtonTapped
    case success
		case update(code: String)
		
		@CasePathable
		public enum Delegate: Equatable {
			case navigateToMenu
			case popToRoot
		}
  }
  
  public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .delegate:
					return .none
					
				case .popButtonTapped:
					return .send(.delegate(.popToRoot))
					
				case .success:
					return .none
					
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
							state.userSettings.passcode = state.code
							return .send(.delegate(.navigateToMenu))
						} else {
							state.step = .firstCode
							state.code = ""
							state.firstCode = ""
							state.codeNotMatched = true
						}
					}
					return .none
			}
		}
  }
}
