import Foundation
import ComposableArchitecture
import EntriesFeature
import Models
import UIApplicationClient
import UserDefaultsClient

@Reducer
public struct LayoutFeature {
	@ObservableState
  public struct State: Equatable {
		@Presents public var alert: AlertState<OnboardingAlert>?
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var isAppClip = false
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
  }

  public enum Action: ViewAction, Equatable {
		case alert(PresentationAction<OnboardingAlert>)
		case entries(IdentifiedActionOf<DayEntriesRow>)
		case delegate(Delegate)
    case layoutChanged(LayoutType)
		case view(View)
		
		@CasePathable
		public enum Alert: Equatable {
			case skip
		}
		@CasePathable
		public enum Delegate: Equatable {
			case navigateToHome
			case navigateToTheme
		}
		@CasePathable
		public enum View: Equatable {
			case skipAlertButtonTapped
			case themeButtonTapped
		}
  }
  
	@Dependency(\.applicationClient.setUserInterfaceStyle) var setUserInterfaceStyle
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .alert(.presented(.skip)):
					state.userSettings.hasShownOnboarding = true
					return .run { send in
						await send(.delegate(.navigateToHome))
					}
					
				case .alert:
					return .none
				
				case .delegate:
					return .none
					
				case .entries:
					return .none
					
				case let .layoutChanged(layoutChanged):
					state.userSettings.appearance.layoutType = layoutChanged
					state.entries = fakeEntries
					return .none
					
				case let .view(viewAction):
					switch viewAction {
						case .skipAlertButtonTapped:
							state.alert = .skip
							return .none
							
						case .themeButtonTapped:
							return .send(.delegate(.navigateToTheme))
					}
			}
		}
		.ifLet(\.$alert, action: \.alert)
		.forEach(\.entries, action: \.entries) {
			DayEntriesRow()
		}
	}
}

