import Foundation
import ComposableArchitecture
import UserDefaultsClient
import FeedbackGeneratorClient

public struct WelcomeFeature: Reducer {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var alert: AlertState<Action.Alert>?
		public var privacy: PrivacyFeature.State?
		public var navigatePrivacy: Bool = false
		public var skipAlert: AlertState<WelcomeFeature.Action>?
		public var selectedPage = 0
		public var tabViewAnimated = false
		public var isAppClip = false
		
		public init(
			privacy: PrivacyFeature.State? = nil,
			navigatePrivacy: Bool = false,
			isAppClip: Bool = false
		) {
			self.privacy = privacy
			self.navigatePrivacy = navigatePrivacy
			self.isAppClip = isAppClip
		}
	}
	
	public enum Action: Equatable {
		case alert(PresentationAction<Alert>)
		case delegate(Delegate)
		case privacy(PrivacyFeature.Action)
		case navigationPrivacy(Bool)
		case skipAlertButtonTapped
		case selectedPage(Int)
		case startTimer
		case nextPage
		
		public enum Alert: Equatable {
			case skip
		}
		public enum Delegate: Equatable {
			case goToHome
		}
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.continuousClock) private var clock
	private enum CancelID {
		case timer
	}
	public var body: some ReducerOf<Self> {
		Reduce(self.core)
			.ifLet(\.privacy, action: /Action.privacy) {
				PrivacyFeature()
			}
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
			case .alert(.presented(.skip)):
				return .merge(
					.run { _ in await self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true) },
					.cancel(id: CancelID.timer),
					.run { send in await send(.delegate(.goToHome)) }
				)
				
			case .alert:
				return .none
				
			case .delegate:
				return .none
				
			case let .navigationPrivacy(value):
				state.privacy = value ? .init(isAppClip: state.isAppClip) : nil
				state.navigatePrivacy = value
				return .cancel(id: CancelID.timer)
				
			case .privacy:
				return .none
				
			case .skipAlertButtonTapped:
				state.alert = AlertState {
					.init("OnBoarding.Skip.Title".localized)
				} actions: {
					ButtonState(role: .cancel, label: { .init("Cancel".localized) })
					ButtonState(role: .destructive, action: .skip, label: { .init("OnBoarding.Skip".localized) })
				}
				return .none
				
			case .startTimer:
				return .run { send in
					while true {
						try await self.clock.sleep(for: .seconds(5))
						await send(.nextPage)
					}
				}
				.cancellable(id: CancelID.timer)
				
			case let .selectedPage(value):
				state.selectedPage = value
				return .merge(
					.cancel(id: CancelID.timer),
					.run { send in
						while true {
							try await self.clock.sleep(for: .seconds(5))
							await send(.nextPage)
						}
					}
						.cancellable(id: CancelID.timer)
				)
				
			case .nextPage:
				state.tabViewAnimated = true
				if state.selectedPage == 2 {
					state.selectedPage = 0
				} else {
					state.selectedPage += 1
				}
				return .none
		}
	}
}
