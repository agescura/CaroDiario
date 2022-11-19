//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

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
  cameraReducer
    .optional()
    .pullback(
      state: \SettingsState.cameraState,
      action: /SettingsAction.cameraAction,
      environment: {
        CameraEnvironment(
          avCaptureDeviceClient: $0.avCaptureDeviceClient,
          feedbackGeneratorClient: $0.feedbackGeneratorClient,
          applicationClient: $0.applicationClient,
          mainQueue: $0.mainQueue
        )
      }
    ),
  appearanceReducer
    .optional()
    .pullback(
      state: \SettingsState.appearanceState,
      action: /SettingsAction.appearanceAction,
      environment: {
        AppearanceEnvironment(
          applicationClient: $0.applicationClient,
          feedbackGeneratorClient: $0.feedbackGeneratorClient,
          setUserInterfaceStyle: $0.setUserInterfaceStyle
        )
      }
    ),
  microphoneReducer
    .optional()
    .pullback(
      state: \SettingsState.microphoneState,
      action: /SettingsAction.microphoneAction,
      environment: {
        MicrophoneEnvironment(
          avAudioSessionClient: $0.avAudioSessionClient,
          feedbackGeneratorClient: $0.feedbackGeneratorClient,
          applicationClient: $0.applicationClient,
          mainQueue: $0.mainQueue
        )
      }
    ),
  agreementsReducer
    .optional()
    .pullback(
      state: \SettingsState.agreementsState,
      action: /SettingsAction.agreementsAction,
      environment: {
        AgreementsEnvironment(
          applicationClient: $0.applicationClient
        )
      }
    ),
  exportReducer
    .optional()
    .pullback(
      state: \SettingsState.exportState,
      action: /SettingsAction.exportAction,
      environment: {
        ExportEnvironment(
          fileClient: $0.fileClient,
          applicationClient: $0.applicationClient,
          pdfKitClient: $0.pdfKitClient,
          date: $0.date
        )
      }
    ),
  AnyReducer(
    EmptyReducer()
      .ifLet(\SettingsState.aboutState, action: /SettingsAction.aboutAction) {
        About()
      }
  ),
  languageReducer
    .optional()
    .pullback(
      state: \SettingsState.languageState,
      action: /SettingsAction.languageAction,
      environment: { _ in
        LanguageEnvironment()
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
        
      case .appearanceAction:
        return .none
        
      case let .navigateLanguage(value):
        state.route = value ? .language(
          .init(language: state.language)
        ) : nil
        return .none
        
      case .languageAction:
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
        
      case .cameraAction:
        return .none
        
      case let .navigateCamera(value):
        state.route = value ? .camera(
          .init(cameraStatus: state.cameraStatus)
        ) : nil
        return .none
        
      case let .navigateAgreements(value):
        state.route = value ? .agreements(.init()) : nil
        return .none
        
      case .agreementsAction:
        return .none
        
      case .reviewStoreKit:
        return environment.storeKitClient.requestReview()
          .fireAndForget()
        
      case let .navigateExport(value):
        state.route = value ? .export(.init()) : nil
        return .none
        
      case .exportAction:
        return .none
        
      case let .navigateAbout(value):
        state.route = value ? .about(.init()) : nil
        return .none
        
      case .aboutAction:
        return .none
      }
    }
)
