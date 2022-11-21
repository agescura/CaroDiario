import Foundation
import ComposableArchitecture
import MicrophoneFeature
import AboutFeature
import AgreementsFeature
import AppearanceFeature
import CameraFeature
import ExportFeature
import LanguageFeature
import PasscodeFeature
import Models

public let settingsReducer: Reducer<
  SettingsState,
  SettingsAction,
  SettingsEnvironment
> = .combine(
  activatePasscodeReducer
    .optional()
    .pullback(
      state: \SettingsState.activateState,
      action: /SettingsAction.activatePasscodeAction,
      environment: {
        ActivatePasscodeEnvironment(
          localAuthenticationClient: $0.localAuthenticationClient,
          mainQueue: $0.mainQueue
        )
      }
    ),
  menuPasscodeReducer
    .optional()
    .pullback(
      state: \SettingsState.menuState,
      action: /SettingsAction.menuPasscodeAction,
      environment: {
        MenuPasscodeEnvironment(
          localAuthenticationClient: $0.localAuthenticationClient,
          mainQueue: $0.mainQueue
        )
      }
    ),
  AnyReducer(
    EmptyReducer()
      .ifLet(\.appearance, action: /SettingsAction.appearance) {
        Appearance()
      }
      .ifLet(\.agreements, action: /SettingsAction.agreements) {
        Agreements()
      }
      .ifLet(\.camera, action: /SettingsAction.camera) {
        Camera()
      }
      .ifLet(\.about, action: /SettingsAction.about) {
        About()
      }
      .ifLet(\.export, action: /SettingsAction.export) {
        Export()
      }
      .ifLet(\.languageState, action: /SettingsAction.language) {
        Language()
      }
      .ifLet(\.microphoneState, action: /SettingsAction.microphoneAction) {
        Microphone()
      }
  ),
  
    .init { state, action, environment in
      switch action {
        
      case .onAppear:
        return environment.localAuthenticationClient.determineType()
          .map(SettingsAction.biometricResult)
        
      case let .navigateAppearance(value):
        state.route = value ? .appearance(
          .init(
            styleType: state.styleType,
            layoutType: state.layoutType,
            themeType: state.themeType,
            iconAppType: state.iconAppType
          )
        ) : nil
        return .none
        
      case .appearance:
        return .none
        
      case let .navigateLanguage(value):
        state.route = value ? .language(
          .init(language: state.language)
        ) : nil
        return .none
        
      case .language:
        return .none
        
      case let .toggleShowSplash(isOn):
        state.showSplash = isOn
        return .none
        
      case let .biometricResult(result):
        state.authenticationType = result
        return .none
        
      case .activatePasscodeAction(.insertPasscodeAction(.navigateMenuPasscode(true))):
        state.hasPasscode = true
        return .none
        
      case .menuPasscodeAction(.actionSheetTurnoffTapped),
          .activatePasscodeAction(.insertPasscodeAction(.menuPasscodeAction(.actionSheetTurnoffTapped))):
        state.hasPasscode = false
        return Effect(value: .navigateActivatePasscode(false))
          .delay(for: 0.1, scheduler: environment.mainQueue)
          .eraseToEffect()
        
      case .activatePasscodeAction(.insertPasscodeAction(.menuPasscodeAction(.popToRoot))),
          .activatePasscodeAction(.insertPasscodeAction(.popToRoot)),
          .menuPasscodeAction(.popToRoot),
          .activatePasscodeAction(.insertPasscodeAction(.success)):
        return Effect(value: .navigateActivatePasscode(false))
        
      case .activatePasscodeAction:
        return .none
        
      case let .navigateActivatePasscode(value):
        state.route = value ? .activate(
          .init(
            faceIdEnabled: state.faceIdEnabled,
            hasPasscode: state.hasPasscode
          )
        ) : nil
        return .none
        
      case .menuPasscodeAction:
        return .none
        
      case let .navigateMenuPasscode(value):
        state.route = value ? .menu(
          .init(
            authenticationType: state.authenticationType,
            optionTimeForAskPasscode: state.optionTimeForAskPasscode,
            faceIdEnabled: state.faceIdEnabled
          )
        ) : nil
        return .none
        
      case .microphoneAction:
        return .none
        
      case let .navigateMicrophone(value):
        state.route = value ? .microphone(
          .init(microphoneStatus: state.microphoneStatus)
        ) : nil
        return .none
        
      case .camera:
        return .none
        
      case let .navigateCamera(value):
        state.route = value ? .camera(
          .init(cameraStatus: state.cameraStatus)
        ) : nil
        return .none
        
      case let .navigateAgreements(value):
        state.route = value ? .agreements(.init()) : nil
        return .none
        
      case .agreements:
        return .none
        
      case .reviewStoreKit:
        return environment.storeKitClient.requestReview()
          .fireAndForget()
        
      case let .navigateExport(value):
        state.route = value ? .export(.init()) : nil
        return .none
        
      case .export:
        return .none
        
      case let .navigateAbout(value):
        state.route = value ? .about(.init()) : nil
        return .none
        
      case .about:
        return .none
      }
    }
)
