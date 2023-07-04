import ComposableArchitecture
import EntriesFeature
import Foundation
import UserDefaultsClient

public struct PrivacyFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var alert: AlertState<Action.Alert>?
		@PresentationState public var style: StyleFeature.State?
		public var isAppClip = false
		
		public init(
			isAppClip: Bool = false,
			style: StyleFeature.State? = nil
		) {
			self.isAppClip = isAppClip
			self.style = style
		}
	}
	
	public enum Action: Equatable {
		case alert(PresentationAction<Alert>)
		case alertButtonTapped
		case delegate(Delegate)
		case style(PresentationAction<StyleFeature.Action>)
		case styleButtonTapped
		
		public enum Alert: Equatable {
			case skipButtonTapped
		}
		
		public enum Delegate: Equatable {
			case skip
		}
	}
	
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .alertButtonTapped:
					state.alert = .alert
					return .none
					
				case .alert(.presented(.skipButtonTapped)):
					return .run { send in
						await send(.delegate(.skip))
					}
					
				case .alert:
					return .none
					
				case .delegate:
					return .none
					
				case .style:
					return .none
					
				case .styleButtonTapped:
					let styleType = self.userDefaultsClient.userSettings.appearance.styleType
					let layoutType = self.userDefaultsClient.userSettings.appearance.layoutType
					
					state.style = StyleFeature.State(
						entries: fakeEntries(
							with: styleType,
							layout: layoutType
						),
						isAppClip: state.isAppClip,
						layoutType: layoutType,
						styleType: styleType
					)
					return .none
			}
		}
		.ifLet(\.$alert, action: /Action.alert)
		.ifLet(\.$style, action: /Action.style) {
			StyleFeature()
		}
	}
}

extension AlertState where Action == PrivacyFeature.Action.Alert {
	static var alert: Self {
		AlertState {
			TextState("OnBoarding.Skip.Title".localized)
		} actions: {
			ButtonState.cancel(TextState("Cancel".localized))
			ButtonState.destructive(TextState("OnBoarding.Skip".localized), action: .send(.skipButtonTapped))
		} message: {
			TextState("OnBoarding.Skip.Alert".localized)
		}
	}
}
