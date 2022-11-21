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
    case splash(Splash.State)
    case onBoarding(Welcome.State)
    case lockScreen(LockScreen.State)
    case home(Home.State)
  }

  public enum Action: Equatable {
    case splash(Splash.Action)
    case onBoarding(Welcome.Action)
    case lockScreen(LockScreen.Action)
    case home(Home.Action)
  }
  
  public var body: some ReducerProtocolOf<Self> {
    Scope(state: /State.splash, action: /Action.splash) {
      Splash()
    }
    Scope(state: /State.onBoarding, action: /Action.onBoarding) {
      Welcome()
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
  let store: StoreOf<AppReducer>
  
  public init(
    store: StoreOf<AppReducer>
  ) {
    self.store = store
  }
  
  public var body: some View {
    SwitchStore(self.store) {
      CaseLet(
        state: /AppReducer.State.splash,
        action: AppReducer.Action.splash,
        then: SplashView.init(store:)
      )
      CaseLet(
        state: /AppReducer.State.onBoarding,
        action: AppReducer.Action.onBoarding,
        then: WelcomeView.init(store:)
      )
      CaseLet(
        state: /AppReducer.State.lockScreen,
        action: AppReducer.Action.lockScreen,
        then: LockScreenView.init(store:)
      )
      CaseLet(
        state: /AppReducer.State.home,
        action: AppReducer.Action.home,
        then: HomeView.init(store:)
      )
    }
  }
}
