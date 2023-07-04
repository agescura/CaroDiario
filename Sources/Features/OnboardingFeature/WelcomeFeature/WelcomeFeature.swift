import ComposableArchitecture
import FeedbackGeneratorClient
import Foundation
import UserDefaultsClient

public struct WelcomeFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var alert: AlertState<Action.Alert>?
		public var isAppClip = false
		@PresentationState public var privacy: PrivacyFeature.State?
		public var selectedPage = 0
		public var tabViewAnimated = false
		
		public init(
			isAppClip: Bool = false,
			privacy: PrivacyFeature.State? = nil
		) {
			self.isAppClip = isAppClip
			self.privacy = privacy
		}
	}
	
	public enum Action: Equatable {
		case alert(PresentationAction<Alert>)
		case alertButtonTapped
		case delegate(Delegate)
		case nextPage
		case privacy(PresentationAction<PrivacyFeature.Action>)
		case privacyButtonTapped
		case selectedPage(Int)
		
		public enum Alert: Equatable {
			case skipButtonTapped
		}
		
		public enum Delegate: Equatable {
			case skip
		}
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	
	private enum CancelID {
		case timer
	}
	
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
					return .cancel(id: CancelID.timer)
					
				case .nextPage:
					state.tabViewAnimated = true
					if state.selectedPage == 2 {
						state.selectedPage = 0
					} else {
						state.selectedPage += 1
					}
					return .none
					
				case .privacy:
					return .none
					
				case .privacyButtonTapped:
					state.privacy = .init(isAppClip: state.isAppClip)
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
		.ifLet(\.$alert, action: /Action.alert)
		.ifLet(\.$privacy, action: /Action.privacy) {
			PrivacyFeature()
		}
	}
}

extension AlertState where Action == WelcomeFeature.Action.Alert {
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
