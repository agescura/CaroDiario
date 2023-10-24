import SwiftUI
import ComposableArchitecture
import SplashFeature
import OnboardingFeature
import HomeFeature
import LockScreenFeature

public struct AppView: View {
	private let store: StoreOf<AppFeature>
	
	public init(
		store: StoreOf<AppFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		SwitchStore(self.store) { state in
			switch state {
				case .empty:
					Color.chambray
						.ignoresSafeArea()
				case .splash:
					CaseLet(
						/AppFeature.State.splash,
						 action: AppFeature.Action.splash,
						 then: SplashView.init
					)
				case .onBoarding:
					CaseLet(
						/AppFeature.State.onBoarding,
						 action: AppFeature.Action.onBoarding,
						 then: WelcomeView.init
					)
				case .lockScreen:
					CaseLet(
						/AppFeature.State.lockScreen,
						 action: AppFeature.Action.lockScreen,
						 then: LockScreenView.init
					)
				case .home:
					CaseLet(
						/AppFeature.State.home,
						 action: AppFeature.Action.home,
						 then: HomeView.init
					)
			}
		}
	}
}
