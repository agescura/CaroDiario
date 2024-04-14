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
  
  public enum Action: Equatable {
		case delegate(Delegate)
		case insertButtonTapped
		
		@CasePathable
		public enum Delegate: Equatable {
			case navigateToInsert
		}
  }
  
  public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .delegate:
					return .none
				case .insertButtonTapped:
					return .send(.delegate(.navigateToInsert))
			}
		}
  }
}
