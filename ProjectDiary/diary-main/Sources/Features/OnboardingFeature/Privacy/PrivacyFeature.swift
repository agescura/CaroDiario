import Foundation
import ComposableArchitecture
import UserDefaultsClient
import EntriesFeature

public struct PrivacyFeature: Reducer {
  public init() {}
  
  public struct State: Equatable {
		@PresentationState public var alert: AlertState<Action.Alert>?
		public var isAppClip = false
		public var navigateStyle: Bool = false
		public var skipAlert: AlertState<PrivacyFeature.Action>?
    public var style: StyleFeature.State? = nil
    
    public init(
			isAppClip: Bool = false,
			navigateStyle: Bool = false,
      style: StyleFeature.State? = nil
    ) {
			self.isAppClip = isAppClip
			self.navigateStyle = navigateStyle
      self.style = style
    }
  }
  
  public enum Action: Equatable {
		case alert(PresentationAction<Alert>)
		case cancelSkipAlert
		case delegate(Delegate)
		case navigationStyle(Bool)
		case skipAlertButtonTapped
    case style(StyleFeature.Action)
		
		public enum Alert: Equatable {
			case skip
		}
		public enum Delegate: Equatable {
			case goToHome
		}
  }
  
  @Dependency(\.userDefaultsClient) var userDefaultsClient
  
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .alert(.presented(.skip)):
					state.skipAlert = nil
					return .run { send in
						await self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
						await send(.delegate(.goToHome))
					}
					
				case .alert:
					return .none
					
				case .cancelSkipAlert:
					state.skipAlert = nil
					return .none
					
				case .delegate:
					return .none
					
				case let .navigationStyle(value):
					let styleType = self.userDefaultsClient.styleType
					let layoutType = self.userDefaultsClient.layoutType
					
					state.navigateStyle = value
					state.style = value ? StyleFeature.State(
						entries: fakeEntries(with: styleType,
																 layout: layoutType),
						isAppClip: state.isAppClip,
						layoutType: layoutType,
						styleType: styleType) : nil
					return .none
					
				case .skipAlertButtonTapped:
					state.alert = AlertState {
						TextState("OnBoarding.Skip.Title".localized)
					} actions: {
						ButtonState(role: .cancel, label: { TextState("Cancel".localized) })
						ButtonState(role: .destructive, action: .skip, label: { TextState("OnBoarding.Skip".localized) })
					} message: {
						TextState("OnBoarding.Skip.Alert".localized)
					}
					return .none
					
				case .style:
					return .none
			}
		}
		.ifLet(\.style, action: /Action.style) {
			StyleFeature()
		}
		.ifLet(\.$alert, action: /Action.alert)
	}
}
