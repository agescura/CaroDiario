import ComposableArchitecture
import Foundation
import Models
import UserDefaultsClient

@Reducer
public struct PrivacyFeature {
  public init() {}
  
	@ObservableState
  public struct State: Equatable {
		@Presents public var alert: AlertState<OnboardingAlert>?
		public var isAppClip: Bool
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
    public init(
			alert: AlertState<OnboardingAlert>? = nil,
			isAppClip: Bool = false
    ) {
			self.alert = alert
			self.isAppClip = isAppClip
    }
  }
  
  public enum Action: ViewAction, Equatable {
		case alert(PresentationAction<OnboardingAlert>)
		case delegate(Delegate)
		case view(View)
		
		@CasePathable
		public enum Alert: Equatable {
			case skip
		}
		@CasePathable
		public enum Delegate: Equatable {
			case navigateToHome
			case navigateToStyle
		}
		@CasePathable
		public enum View: Equatable {
			case skipAlertButtonTapped
			case styleButtonTapped
		}
  }
  
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .alert(.presented(.skip)):
					state.userSettings.hasShownOnboarding = true
					return .run { send in
						await send(.delegate(.navigateToHome))
					}
					
				case .alert(.dismiss):
					state.alert = nil
					return .none
					
				case .delegate:
					return .none
					
				case let .view(viewAction):
					switch viewAction {
						case .skipAlertButtonTapped:
							state.alert = .skip
							return .none
							
						case .styleButtonTapped:
							return .send(.delegate(.navigateToStyle))
					}
			}
		}
		.ifLet(\.$alert, action: \.alert)
	}
}
