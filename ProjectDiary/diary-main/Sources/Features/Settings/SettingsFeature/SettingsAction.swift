import Foundation
import Models
import MicrophoneFeature
import AboutFeature
import AgreementsFeature
import AppearanceFeature
import CameraFeature
import ExportFeature
import LanguageFeature
import PasscodeFeature

public enum SettingsAction: Equatable {
  case onAppear
  
  case toggleShowSplash(isOn: Bool)
  case biometricResult(LocalAuthenticationType)
  
  case appearance(Appearance.Action)
  case navigateAppearance(Bool)
  
  case language(Language.Action)
  case navigateLanguage(Bool)
  
  case activatePasscodeAction(ActivatePasscodeAction)
  case navigateActivatePasscode(Bool)
  
  case menuPasscodeAction(MenuPasscodeAction)
  case navigateMenuPasscode(Bool)
  
  case camera(Camera.Action)
  case navigateCamera(Bool)
  
  case microphoneAction(Microphone.Action)
  case navigateMicrophone(Bool)
  
  case agreements(Agreements.Action)
  case navigateAgreements(Bool)
  
  case reviewStoreKit
  
  case export(Export.Action)
  case navigateExport(Bool)
  
  case about(About.Action)
  case navigateAbout(Bool)
}
