import Foundation
import ComposableArchitecture
import UserDefaultsClient
import FeedbackGeneratorClient

public struct WelcomeFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var alert: AlertState<Action.Alert>?
		@PresentationState public var privacy: Privacy.State?
		public var selectedPage = 0
		public var tabViewAnimated = false
		public var isAppClip = false
		
		public init(
			privacy: Privacy.State? = nil,
			isAppClip: Bool = false
		) {
			self.privacy = privacy
			self.isAppClip = isAppClip
		}
	}
	
	public enum Action: Equatable {
		case alert(PresentationAction<Alert>)
		case privacy(PresentationAction<Privacy.Action>)
		case alertButtonTapped
		case nextPage
		case privacyButtonTapped
		case selectedPage(Int)
		case startTimer
		
		public enum Alert: Equatable {
			case skipButtonTapped
		}
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.continuousClock) private var clock
	private enum TimerID: Hashable {}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce(self.core)
			.ifLet(\.$alert, action: /Action.alert)
			.ifLet(\.$privacy, action: /Action.privacy) {
				Privacy()
			}
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> EffectTask<Action> {
		switch action {
			case .alert(.presented(.skipButtonTapped)):
				return .merge(
					.fireAndForget { await self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true) },
					.cancel(id: TimerID.self)
				)
				
			case .alert:
				return .none
				
			case .privacy:
				return .none
				
			case .alertButtonTapped:
				state.alert = AlertState {
					TextState("OnBoarding.Skip.Title".localized)
				} actions: {
					ButtonState.cancel(TextState("Cancel".localized))
					ButtonState.destructive(TextState("OnBoarding.Skip".localized), action: .send(.skipButtonTapped))
				} message: {
					TextState("OnBoarding.Skip.Alert".localized)
				}
				return .none
				
			case .privacyButtonTapped:
				state.privacy = .init(isAppClip: state.isAppClip)
				return .cancel(id: TimerID.self)
				
			case .nextPage:
				state.tabViewAnimated = true
				if state.selectedPage == 2 {
					state.selectedPage = 0
				} else {
					state.selectedPage += 1
				}
				return .none
				
			case let .selectedPage(value):
				state.selectedPage = value
				return .merge(
					.cancel(id: TimerID.self),
					.run { send in
						while true {
							try await self.clock.sleep(for: .seconds(5))
							await send(.nextPage)
						}
					}
						.cancellable(id: TimerID.self)
				)
				
			case .startTimer:
				return .run { send in
					while true {
						try await self.clock.sleep(for: .seconds(5))
						await send(.nextPage)
					}
				}
				.cancellable(id: TimerID.self)
		}
	}
}
