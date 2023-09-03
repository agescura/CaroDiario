import ComposableArchitecture
import SwiftUI
import SplashFeature
import OnboardingFeature
import UserDefaultsClient
import FeedbackGeneratorClient

public struct SwitchClipFeature: Reducer {
	public init() {}
	
	public enum State: Equatable {
		case splash(SplashFeature.State)
		case onBoarding(WelcomeFeature.State)
	}
	
	public enum Action: Equatable {
		case splash(SplashFeature.Action)
		case onBoarding(WelcomeFeature.Action)
	}
	
	public var body: some ReducerOf<Self> {
		Scope(state: /State.splash, action: /Action.splash) {
			SplashFeature()
		}
		Scope(state: /State.onBoarding, action: /Action.onBoarding) {
			WelcomeFeature()
		}
	}
}

public struct SwitchClipView: View {
	private let store: StoreOf<SwitchClipFeature>
	
	public init(
		store: StoreOf<SwitchClipFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		SwitchStore(self.store) { state in
			switch state {
				case .splash:
					CaseLet(
						/SwitchClipFeature.State.splash,
						 action: SwitchClipFeature.Action.splash,
						 then: SplashView.init
					)
				case .onBoarding:
					CaseLet(
						/SwitchClipFeature.State.onBoarding,
						 action: SwitchClipFeature.Action.onBoarding,
						 then: WelcomeView.init
					)
			}
		}
	}
}
