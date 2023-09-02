import ComposableArchitecture
import FeedbackGeneratorClient
import Foundation
import UserDefaultsClient

public struct WelcomeFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var destination: Destination.State?
		public var selectedPage = 0
		public var tabViewAnimated = false
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
		case nextPage
		case privacyButtonTapped
		case selectedPage(Int)
		
		public enum Delegate: Equatable {
			case skip
		}
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.mainQueue) private var mainQueue
	private enum CancelID {
		case timer
	}
	
	public struct Destination: ReducerProtocol {
		public enum State: Equatable {
			case alert(AlertState<Action.Alert>)
			case privacy(PrivacyFeature.State)
		}
		
		public enum Action: Equatable {
			case alert(Alert)
			case privacy(PrivacyFeature.Action)
			
			public enum Alert: Equatable {
				case skipButtonTapped
			}
		}
		
		public var body: some ReducerProtocolOf<Self> {
			Scope(state: /State.alert, action: /Action.alert) {}
			Scope(state: /State.privacy, action: /Action.privacy) {
				PrivacyFeature()
			}
		}
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .alertButtonTapped:
					state.destination = .alert(.skip)
					return .none
					
				case .destination(.presented(.alert(.skipButtonTapped))):
					return .run { send in
						self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
						await send(.delegate(.skip))
					}
					
				case .delegate:
					return .cancel(id: CancelID.timer)
					
				case .destination:
					return .none
					
				case .nextPage:
					state.tabViewAnimated = true
					if state.selectedPage == 2 {
						state.selectedPage = 0
					} else {
						state.selectedPage += 1
					}
					return .none
					
				case .privacyButtonTapped:
					state.destination = .privacy(
						PrivacyFeature.State(isAppClip: state.isAppClip)
					)
					return .cancel(id: CancelID.timer)
					
				case let .selectedPage(value):
					state.selectedPage = value
					return .run { send in
						while true {
							try await self.mainQueue.sleep(for: .seconds(5))
							await send(.nextPage)
						}
					}
					.cancellable(id: CancelID.timer)
			}
		}
		.ifLet(\.$destination, action: /Action.destination) {
			Destination()
		}
	}
}

extension AlertState where Action == WelcomeFeature.Destination.Action.Alert {
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
