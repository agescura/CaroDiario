import SwiftUI
import ComposableArchitecture
import SplashFeature
import OnboardingFeature
import HomeFeature
import UserDefaultsClient
import CoreDataClient
import FileClient
import LockScreenFeature
import LocalAuthenticationClient
import UIApplicationClient
import AVCaptureDeviceClient
import FeedbackGeneratorClient
import AVAudioSessionClient
import AVAudioPlayerClient
import AVAudioRecorderClient
import StoreKitClient
import PDFKitClient
import AVAssetClient

public struct AppReducer: ReducerProtocol {
	public init() {}
	
	public enum State: Equatable {
		case splash(SplashFeature.State)
		case onBoarding(WelcomeFeature.State)
		case lockScreen(LockScreen.State)
		case home(Home.State)
	}
	
	public enum Action: Equatable {
		case splash(SplashFeature.Action)
		case onBoarding(WelcomeFeature.Action)
		case lockScreen(LockScreen.Action)
		case home(Home.Action)
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Scope(state: /State.splash, action: /Action.splash) {
			SplashFeature()
		}
		Scope(state: /State.onBoarding, action: /Action.onBoarding) {
			WelcomeFeature()
		}
		Scope(state: /State.lockScreen, action: /Action.lockScreen) {
			LockScreen()
		}
		Scope(state: /State.home, action: /Action.home) {
			Home()
		}
	}
}

public struct AppView: View {
	private let store: StoreOf<AppReducer>
	
	public init(
		store: StoreOf<AppReducer>
	) {
		self.store = store
	}
	
	public var body: some View {
		SwitchStore(self.store) { state in
			switch state {
				case .splash:
					CaseLet(
						/AppReducer.State.splash,
						 action: AppReducer.Action.splash,
						 then: SplashView.init
					)
				case .onBoarding:
					CaseLet(
						/AppReducer.State.onBoarding,
						 action: AppReducer.Action.onBoarding,
						 then: WelcomeView.init
					)
				case .lockScreen:
					CaseLet(
						/AppReducer.State.lockScreen,
						 action: AppReducer.Action.lockScreen,
						 then: LockScreenView.init
					)
				case .home:
					CaseLet(
						/AppReducer.State.home,
						 action: AppReducer.Action.home,
						 then: HomeView.init
					)
			}
		}
	}
}
