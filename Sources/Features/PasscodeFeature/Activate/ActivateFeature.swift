import ComposableArchitecture
import Foundation
import Models

@Reducer
public struct ActivateFeature {
  public init() {}
  
	@ObservableState
  public struct State: Equatable {
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
    
    public init() {}
  }
  
  public enum Action: ViewAction, Equatable {
		case delegate(Delegate)
		case view(View)
		
		@CasePathable
		public enum Delegate: Equatable {
			case navigateToInsert
		}
		@CasePathable
		public enum View: Equatable {
			case insertButtonTapped
		}
  }
  
  public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .delegate:
					return .none
				case .view(.insertButtonTapped):
					return .send(.delegate(.navigateToInsert))
			}
		}
  }
}
