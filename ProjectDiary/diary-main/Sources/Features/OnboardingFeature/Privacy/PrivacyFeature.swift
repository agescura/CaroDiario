import ComposableArchitecture
import EntriesFeature
import Foundation
import UserDefaultsClient

public struct PrivacyFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var destination: Destination.State?
		public var isAppClip = false
		
		public init(
			destination: Destination.State? = nil,
			isAppClip: Bool = false
		) {
			self.destination = destination
			self.isAppClip = isAppClip
		}
	}
	
	public enum Action: Equatable {
		case alertButtonTapped
		case delegate(Delegate)
		case destination(PresentationAction<Destination.Action>)
		case styleButtonTapped
		
		public enum Delegate: Equatable {
			case skip
		}
	}
	
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	
	public struct Destination: ReducerProtocol {
		public enum State: Equatable {
			case alert(AlertState<Action.Alert>)
			case style(StyleFeature.State)
		}
		
		public enum Action: Equatable {
			case alert(Alert)
			case style(StyleFeature.Action)
			
			public enum Alert {
				case skipButtonTapped
			}
		}
		
		public var body: some ReducerProtocolOf<Self> {
			Scope(state: /State.alert, action: /Action.alert) {}
			Scope(state: /State.style, action: /Action.style) {
				StyleFeature()
			}
		}
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .alertButtonTapped:
					state.destination = .alert(.skip)
					return .none
					
				case .delegate:
					return .none
					
				case .destination(.presented(.alert(.skipButtonTapped))):
					return .run { send in
						self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
						await send(.delegate(.skip))
					}
					
				case .destination:
					return .none
					
				case .styleButtonTapped:
					let styleType = self.userDefaultsClient.styleType
					let layoutType = self.userDefaultsClient.layoutType
					state.destination = .style(
						StyleFeature.State(
							entries: fakeEntries(
								with: styleType,
								layout: layoutType
							),
							isAppClip: state.isAppClip,
							layoutType: layoutType,
							styleType: styleType
						)
					)
					return .none
			}
		}
		.ifLet(\.$destination, action: /Action.destination) {
			Destination()
		}
	}
}

extension AlertState where Action == PrivacyFeature.Destination.Action.Alert {
	static var skip: Self {
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
