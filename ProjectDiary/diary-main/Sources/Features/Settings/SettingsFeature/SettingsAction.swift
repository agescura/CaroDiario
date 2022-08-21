//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

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
    
    case appearanceAction(AppearanceAction)
    case navigateAppearance(Bool)
    
    case languageAction(LanguageAction)
    case navigateLanguage(Bool)
    
    case activatePasscodeAction(ActivatePasscodeAction)
    case navigateActivatePasscode(Bool)
    
    case menuPasscodeAction(MenuPasscodeAction)
    case navigateMenuPasscode(Bool)
    
    case cameraAction(CameraAction)
    case navigateCamera(Bool)
    
    case microphoneAction(MicrophoneAction)
    case navigateMicrophone(Bool)
    
    case agreementsAction(AgreementsAction)
    case navigateAgreements(Bool)
    
    case reviewStoreKit
    
    case exportAction(ExportAction)
    case navigateExport(Bool)
    
    case aboutAction(AboutAction)
    case navigateAbout(Bool)
}
