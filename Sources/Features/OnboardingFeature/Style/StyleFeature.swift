import ComposableArchitecture
import Foundation
import Models

@Reducer
public struct StyleFeature {
  public init() {}
  
	@ObservableState
  public struct State: Equatable {
		@Presents public var alert: AlertState<OnboardingAlert>?
		public var isAppClip = false
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
  }

  public enum Action: ViewAction, Equatable {
		case alert(PresentationAction<OnboardingAlert>)
		case delegate(Delegate)
		case styleChanged(StyleType)
    case view(View)
		
		@CasePathable
		public enum Delegate: Equatable {
			case navigateToHome
			case navigateToLayout
		}
		
		@CasePathable
		public enum View: Equatable {
			case layoutButtonTapped
			case skipAlertButtonTapped
		}
  }
  
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .alert(.presented(.skip)):
					state.alert = nil
					state.$userSettings.hasShownOnboarding.withLock { $0 = true }
					return .run { send in
						await send(.delegate(.navigateToHome))
					}
				case .alert(.dismiss):
					state.alert = nil
					return .none
					
				case .delegate:
					return .none

				case let .styleChanged(styleType):
					state.$userSettings.appearance.styleType.withLock { $0 = styleType }
					return .none
					
				case let .view(viewAction):
					switch viewAction {
						case .layoutButtonTapped:
							return .send(.delegate(.navigateToLayout))

						case .skipAlertButtonTapped:
							state.alert = .skip
							return .none
					}
			}
		}
		.ifLet(\.$alert, action: \.alert)
	}
}
