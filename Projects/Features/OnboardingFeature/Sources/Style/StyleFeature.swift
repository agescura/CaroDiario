import ComposableArchitecture
import EntriesFeature
import Foundation
import Models

@Reducer
public struct StyleFeature {
  public init() {}
  
	@ObservableState
  public struct State: Equatable {
		@Presents public var alert: AlertState<OnboardingAlert>?
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var isAppClip = false
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
  }

  public enum Action: Equatable {
		case alert(PresentationAction<OnboardingAlert>)
		case delegate(Delegate)
		case entries(IdentifiedActionOf<DayEntriesRow>)
		case layoutButtonTapped
		case skipAlertButtonTapped
		case styleChanged(StyleType)
    
		@CasePathable
		public enum Delegate: Equatable {
			case navigateToHome
			case navigateToLayout
		}
  }
  
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .alert(.presented(.skip)):
					state.alert = nil
					state.userSettings.hasShownOnboarding = true
					return .run { send in
						await send(.delegate(.navigateToHome))
					}
				case .alert(.dismiss):
					state.alert = nil
					return .none
					
				case .delegate:
					return .none
					
				case .entries:
					return .none
					
				case .layoutButtonTapped:
					return .send(.delegate(.navigateToLayout))

				case .skipAlertButtonTapped:
					state.alert = .skip
					return .none
					
				case let .styleChanged(styleType):
					state.userSettings.appearance.styleType = styleType
					state.entries = fakeEntries
					return .none
			}
		}
		.forEach(\.entries, action: \.entries) {
			DayEntriesRow()
		}
		.ifLet(\.$alert, action: \.alert)
	}
}
