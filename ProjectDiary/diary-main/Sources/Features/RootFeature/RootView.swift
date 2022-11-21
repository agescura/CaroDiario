import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import CoreDataClient
import FileClient
import AppFeature
import LocalAuthenticationClient
import HomeFeature
import Styles
import UIApplicationClient
import AVCaptureDeviceClient
import FeedbackGeneratorClient
import AVAudioSessionClient
import AVAudioPlayerClient
import AVAudioRecorderClient
import StoreKitClient
import PDFKitClient
import AVAssetClient
import Models

public struct RootState: Equatable {
  public var appDelegate: AppDelegateState
  public var featureState: AppReducer.State
  
  public var isFirstStarted = true
  public var isBiometricAlertPresent = false
  
  public enum State {
    case active
    case inactive
    case background
    case unknown
  }
  
  public init(
    appDelegate: AppDelegateState,
    featureState: AppReducer.State
  ) {
    self.appDelegate = appDelegate
    self.featureState = featureState
  }
}

public enum RootAction: Equatable {
  case appDelegate(AppDelegateAction)
  case featureAction(AppReducer.Action)
  
  case setUserInterfaceStyle
  case startFirstScreen
  
  case requestCameraStatus
  case startHome(cameraStatus: AuthorizedVideoStatus)
  
  case process(URL)
  case state(RootState.State)
  case shortcuts
  
  case biometricAlertPresent(Bool)
}

public struct RootEnvironment {
  public let coreDataClient: CoreDataClient
  public let fileClient: FileClient
  public let userDefaultsClient: UserDefaultsClient
  public let localAuthenticationClient: LocalAuthenticationClient
  public let applicationClient: UIApplicationClient
  public let avCaptureDeviceClient: AVCaptureDeviceClient
  public let feedbackGeneratorClient: FeedbackGeneratorClient
  public let avAudioSessionClient: AVAudioSessionClient
  public let avAudioPlayerClient: AVAudioPlayerClient
  public let avAudioRecorderClient: AVAudioRecorderClient
  public let storeKitClient: StoreKitClient
  public let pdfKitClient: PDFKitClient
  public let avAssetClient: AVAssetClient
  public let mainQueue: AnySchedulerOf<DispatchQueue>
  public let backgroundQueue: AnySchedulerOf<DispatchQueue>
  public let date: () -> Date
  public let uuid: () -> UUID
  
  public init(
    coreDataClient: CoreDataClient,
    fileClient: FileClient,
    userDefaultsClient: UserDefaultsClient,
    localAuthenticationClient: LocalAuthenticationClient,
    applicationClient: UIApplicationClient,
    avCaptureDeviceClient: AVCaptureDeviceClient,
    feedbackGeneratorClient: FeedbackGeneratorClient,
    avAudioSessionClient: AVAudioSessionClient,
    avAudioPlayerClient: AVAudioPlayerClient,
    avAudioRecorderClient: AVAudioRecorderClient,
    storeKitClient: StoreKitClient,
    pdfKitClient: PDFKitClient,
    avAssetClient: AVAssetClient,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    date: @escaping () -> Date,
    uuid: @escaping () -> UUID
  ) {
    self.coreDataClient = coreDataClient
    self.fileClient = fileClient
    self.userDefaultsClient = userDefaultsClient
    self.localAuthenticationClient = localAuthenticationClient
    self.applicationClient = applicationClient
    self.avCaptureDeviceClient = avCaptureDeviceClient
    self.feedbackGeneratorClient = feedbackGeneratorClient
    self.avAudioSessionClient = avAudioSessionClient
    self.avAudioPlayerClient = avAudioPlayerClient
    self.avAudioRecorderClient = avAudioRecorderClient
    self.storeKitClient = storeKitClient
    self.pdfKitClient = pdfKitClient
    self.avAssetClient = avAssetClient
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
    self.date = date
    self.uuid = uuid
  }
}

public let rootReducer: Reducer<
  RootState,
  RootAction,
  RootEnvironment
> = .combine(
  appDelegateReducer
    .pullback(
      state: \.appDelegate,
      action: /RootAction.appDelegate,
      environment: { _ in () }
    ),
  AnyReducer(
    Scope(state: \.featureState, action: /RootAction.featureAction) {
      AppReducer()
    }
  ),
  
    .init() { state, action, environment in
      switch action {
        
      case .appDelegate(.didFinishLaunching):
        return Effect(value: .setUserInterfaceStyle)
        
      case .setUserInterfaceStyle:
        return .task { @MainActor in
          await environment.applicationClient.setUserInterfaceStyle(environment.userDefaultsClient.themeType.userInterfaceStyle)
          return .startFirstScreen
        }
        
      case .featureAction(.splash(.finishAnimation)):
        if environment.userDefaultsClient.hasShownFirstLaunchOnboarding {
          if let code = environment.userDefaultsClient.passcodeCode {
            state.featureState = .lockScreen(.init(code: code))
            return .none
          } else {
            return environment.avCaptureDeviceClient.authorizationStatus()
              .map(RootAction.startHome)
          }
        }
        
        state.featureState = .onBoarding(.init())
        return .none
        
      case .featureAction(.onBoarding(.skipAlertAction)),
          .featureAction(.onBoarding(.privacy(.skipAlertAction))):
        return Effect(value: RootAction.requestCameraStatus)
        
      case .featureAction(.onBoarding(.privacy(.style(.layout(.theme(.startButtonTapped)))))):
        return Effect(value: RootAction.requestCameraStatus)
          .delay(for: 0.001, scheduler: environment.mainQueue)
          .eraseToEffect()
        
      case .featureAction(.lockScreen(.matchedCode)):
        return Effect(value: RootAction.requestCameraStatus)
        
      case .featureAction(.home(.settings(.menu(.toggleFaceId(true))))),
          .featureAction(.home(.settings(.activate(.insert(.menu(.toggleFaceId(isOn: true))))))),
          .featureAction(.lockScreen(.checkFaceId)):
        return Effect(value: .biometricAlertPresent(true))
        
      case .featureAction(.home(.settings(.menu(.faceId(response:))))),
          .featureAction(.home(.settings(.activate(.insert(.menu(.faceId(response:))))))),
          .featureAction(.lockScreen(.faceIdResponse)):
        return Effect(value: .biometricAlertPresent(false))
          .delay(for: 10, scheduler: environment.mainQueue)
          .eraseToEffect()
        
      case .featureAction:
        return .none
        
      case .startFirstScreen:
        if environment.userDefaultsClient.hideSplashScreen {
          if let code = environment.userDefaultsClient.passcodeCode {
            state.featureState = .lockScreen(.init(code: code))
            return .none
          } else {
            return environment.avCaptureDeviceClient.authorizationStatus()
              .map(RootAction.startHome)
          }
        }
        
        return Effect(value: RootAction.featureAction(.splash(.startAnimation)))
        
      case .requestCameraStatus:
        return environment.avCaptureDeviceClient.authorizationStatus()
          .map(RootAction.startHome)
        
      case let .startHome(cameraStatus: status):
        state.isFirstStarted = false
        state.featureState = .home(
          .init(
            tabBars: [.entries, .search, .settings],
            sharedState: .init(
              showSplash: !environment.userDefaultsClient.hideSplashScreen,
              styleType: environment.userDefaultsClient.styleType,
              layoutType: environment.userDefaultsClient.layoutType,
              themeType: environment.userDefaultsClient.themeType,
              iconAppType: environment.applicationClient.alternateIconName != nil ? .dark : .light,
              language: Localizable(rawValue: environment.userDefaultsClient.language) ?? .spanish,
              hasPasscode: (environment.userDefaultsClient.passcodeCode ?? "").count > 0,
              cameraStatus: status,
              microphoneStatus: environment.avAudioSessionClient.recordPermission(),
              optionTimeForAskPasscode: environment.userDefaultsClient.optionTimeForAskPasscode,
              faceIdEnabled: environment.userDefaultsClient.isFaceIDActivate
            )
          )
        )
        return Effect(value: RootAction.featureAction(.home(.starting)))
        
      case let .process(url):
        return .none
        
      case .state(.active):
        if state.isFirstStarted {
          return .none
        }
        if state.isBiometricAlertPresent {
          return .none
        }
        if let timeForAskPasscode = environment.userDefaultsClient.timeForAskPasscode,
           timeForAskPasscode > environment.date() {
          return .none
        }
        if let code = environment.userDefaultsClient.passcodeCode {
          state.featureState = .lockScreen(.init(code: code))
          return .none
        }
        return .none
        
      case .state(.background):
        if let timeForAskPasscode = Calendar.current.date(
          byAdding: .minute,
          value: environment.userDefaultsClient.optionTimeForAskPasscode,
          to: environment.date()
        ) {
          return environment.userDefaultsClient.setTimeForAskPasscode(timeForAskPasscode)
            .fireAndForget()
        }
        return environment.userDefaultsClient.removeOptionTimeForAskPasscode()
          .fireAndForget()
        
      case .state:
        return .none
        
      case .shortcuts:
        return .none
        
      case let .biometricAlertPresent(value):
        state.isBiometricAlertPresent = value
        return .none
      }
    }
)
  .coreData()
  .userDefaults()

public struct RootView: View {
  let store: Store<RootState, RootAction>
  
  public init(
    store: Store<RootState, RootAction>
  ) {
    self.store = store
  }
  
  public var body: some View {
    AppView(
      store: store.scope(
        state: \.featureState,
        action: RootAction.featureAction
      )
    )
  }
}
