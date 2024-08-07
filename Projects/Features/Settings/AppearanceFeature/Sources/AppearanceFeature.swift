import Foundation
import ComposableArchitecture
import Models
import EntriesFeature

@Reducer
public struct AppearanceFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
	
		public init() {}
  }
  
  public enum Action: Equatable {
		case delegate(Delegate)
		case iconAppButtonTapped
		case layoutButtonTapped
		case styleButtonTapped
		case themeButtonTapped
		
		public enum Delegate: Equatable {
			case navigateToIconApp
			case navigateToLayout
			case navigateToStyle
			case navigateToTheme
		}
  }
  
  public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .delegate:
					return .none
				case .iconAppButtonTapped:
					return .send(.delegate(.navigateToIconApp))
				case .layoutButtonTapped:
					return .send(.delegate(.navigateToLayout))
				case .styleButtonTapped:
					return .send(.delegate(.navigateToStyle))
				case .themeButtonTapped:
					return .send(.delegate(.navigateToTheme))
			}
		}
  }
}
