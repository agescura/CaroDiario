import ComposableArchitecture
import EntriesFeature
import EntryDetailFeature
import Foundation
import HomeFeature
import LockScreenFeature
import Models
import OnboardingFeature
import SplashFeature

@Reducer
public struct AppFeature {
  public init() {}
  
  @Reducer
  public enum Scene {
    case home(HomeFeature)
    case lockScreen(LockScreenFeature)
    case onboarding(WelcomeFeature)
    case splash(SplashFeature)
  }
  
  @ObservableState
  public struct State: Equatable {
    public var appDelegate: AppDelegateState
    public var isFirstStarted = true
    public var isBiometricAlertPresent = false
    public var scene: Scene.State
    @Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
    
    public enum State {
      case active
      case background
      case inactive
      case unknown
    }
    
    public init(
      appDelegate: AppDelegateState = AppDelegateState(),
      scene: Scene.State = .splash(SplashFeature.State())
    ) {
      self.appDelegate = appDelegate
      self.scene = scene
    }
  }
  
  @CasePathable
  public enum Action: Equatable {
    case appDelegate(AppDelegateAction)
    case authorizationStatusResponse(AuthorizedVideoStatus)
    case biometricAlertPresent(Bool)
    case process(URL)
    case scene(Scene.Action)
    case setUserInterfaceStyle
    case shortcuts(ShorcutItem)
    case splashFinished(ShorcutItem?)
    case startHome(cameraStatus: AuthorizedVideoStatus)
    case state(AppFeature.State.State)
  }
  
  @Dependency(\.applicationClient) var applicationClient
  @Dependency(\.avCaptureDeviceClient) var avCaptureDeviceClient
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.mainRunLoop.now.date) var now
  @Dependency(\.avAudioSessionClient) var avAudioSessionClient
  @Dependency(\.uuid) var uuid
  private enum CancelID {
    case coreData
  }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.appDelegate, action: \.appDelegate) {
      EmptyReducer()
    }
    Scope(state: \.scene, action: \.scene) {
      Scene.body
    }
    Reduce { state, action in
      switch action {
      case let .appDelegate(.didFinishLaunching(shortcutItem)):
        return .merge(
          .run { [userInterfaceStyle = state.userSettings.appearance.themeType.userInterfaceStyle, applicationClient] _ in
            await applicationClient.setUserInterfaceStyle(userInterfaceStyle)
          },
          .run { [showSplash = state.userSettings.showSplash] send in
            if !showSplash {
              await send(.splashFinished(shortcutItem))
            }
          },
          .run { [avCaptureDeviceClient] send in
            try await send(.authorizationStatusResponse(avCaptureDeviceClient.authorizationStatus()))
          }
        )
        
      case let .authorizationStatusResponse(authorizedVideoStatus):
        state.$userSettings.authorizedVideoStatus.withLock { $0 = authorizedVideoStatus }
        return .none
        
      case .splashFinished(.add):
        return .send(.shortcuts(.add))
      case .splashFinished(.settings):
        return .send(.shortcuts(.settings))
        
      case .splashFinished:
        if state.userSettings.hasPasscode {
          state.scene = .lockScreen(LockScreenFeature.State())
          return .none
        }
        if !state.userSettings.hasShownOnboarding {
          state.scene = .onboarding(WelcomeFeature.State())
          return .none
        }
        state.scene = .home(HomeFeature.State())
        return .none
        
      case let .scene(sceneAction):
        switch sceneAction {
        case .lockScreen(.delegate(.matchedCode)):
          state.scene = .home(HomeFeature.State())
          return .none
        case .onboarding(.delegate(.navigateToHome)),
            .onboarding(.path(.element(id: _, action: .style(.delegate(.navigateToHome))))),
            .onboarding(.path(.element(id: _, action: .privacy(.delegate(.navigateToHome))))),
            .onboarding(.path(.element(id: _, action: .layout(.delegate(.navigateToHome))))),
            .onboarding(.path(.element(id: _, action: .theme(.delegate(.navigateToHome))))):
          state.scene = .home(HomeFeature.State())
          return .none
        case .splash(.delegate(.animationFinished)):
          return .send(.splashFinished(nil))
        default:
          return .none
        }
        
      case .shortcuts(.add):
        state.scene = .home(
          HomeFeature.State(
            entries: EntriesFeature.State(
              destination: .add(
                EntryDetailFeature.State(
                  entry: .new
                )
              )
            ),
            selectedTabBar: .entries
          )
        )
        return .none
      case .shortcuts(.settings):
        state.scene = .home(
          HomeFeature.State(
            selectedTabBar: .settings
          )
        )
        return .none
      default:
        return .none
      }
    }
  }
}

extension AppFeature.Scene.State: Equatable {}
extension AppFeature.Scene.Action: Equatable {}
