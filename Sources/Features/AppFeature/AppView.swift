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

public struct AppFeature: ReducerProtocol {
  public init() {}
  
  public enum State: Equatable {
    case splash(SplashFeature.State)
    case welcome(WelcomeFeature.State)
    case lockScreen(LockScreen.State)
    case home(HomeFeature.State)
  }

  public enum Action: Equatable {
    case splash(SplashFeature.Action)
    case welcome(WelcomeFeature.Action)
    case lockScreen(LockScreen.Action)
    case home(HomeFeature.Action)
  }
  
  public var body: some ReducerProtocolOf<Self> {
    Scope(state: /State.splash, action: /Action.splash) {
      SplashFeature()
    }
    Scope(state: /State.welcome, action: /Action.welcome) {
      WelcomeFeature()
    }
    Scope(state: /State.lockScreen, action: /Action.lockScreen) {
      LockScreen()
    }
    Scope(state: /State.home, action: /Action.home) {
      HomeFeature()
    }
  }
}

public struct AppView: View {
  let store: StoreOf<AppFeature>
  
  public init(
    store: StoreOf<AppFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
    SwitchStore(self.store) {
      CaseLet(
        state: /AppFeature.State.splash,
        action: AppFeature.Action.splash,
        then: SplashView.init(store:)
      )
      CaseLet(
        state: /AppFeature.State.welcome,
        action: AppFeature.Action.welcome,
        then: WelcomeView.init(store:)
      )
      CaseLet(
        state: /AppFeature.State.lockScreen,
        action: AppFeature.Action.lockScreen,
        then: LockScreenView.init(store:)
      )
      CaseLet(
        state: /AppFeature.State.home,
        action: AppFeature.Action.home,
        then: HomeView.init(store:)
      )
    }
  }
}
