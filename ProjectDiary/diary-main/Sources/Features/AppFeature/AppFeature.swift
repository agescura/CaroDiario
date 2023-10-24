import ComposableArchitecture
import SplashFeature
import OnboardingFeature
import LockScreenFeature
import HomeFeature

public struct AppFeature: Reducer {
	public init() {}
	
	public enum State: Equatable {
		case empty
		case splash(SplashFeature.State)
		case onBoarding(WelcomeFeature.State)
		case lockScreen(LockScreenFeature.State)
		case home(HomeFeature.State)
	}
	
	public enum Action: Equatable {
		case splash(SplashFeature.Action)
		case onBoarding(WelcomeFeature.Action)
		case lockScreen(LockScreenFeature.Action)
		case home(HomeFeature.Action)
	}
	
	public var body: some ReducerOf<Self> {
		Scope(state: /State.splash, action: /Action.splash) {
			SplashFeature()
		}
		Scope(state: /State.onBoarding, action: /Action.onBoarding) {
			WelcomeFeature()
		}
		Scope(state: /State.lockScreen, action: /Action.lockScreen) {
			LockScreenFeature()
		}
		Scope(state: /State.home, action: /Action.home) {
			HomeFeature()
		}
	}
}
