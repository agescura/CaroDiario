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
import Styles
import AVAudioSessionClient

public struct SettingsState: Equatable {
    public var showSplash: Bool
    
    public var styleType: StyleType
    public var layoutType: LayoutType
    public var themeType: ThemeType
    public var iconAppType: IconAppType
    public var language: Localizable = .spanish
    
    public var authenticationType: LocalAuthenticationType = .none
    public var hasPasscode: Bool
    
    public var cameraStatus: AuthorizedVideoStatus
    public var optionTimeForAskPasscode: Int
    
    public var route: Route? = nil {
        didSet {
            if case let .appearance(state) = self.route {
                self.styleType = state.styleType
                self.layoutType = state.layoutType
                self.themeType = state.themeType
                self.iconAppType = state.iconAppType
            }
            if case let .language(state) = self.route {
                self.language = state.language
            }
        }
    }
    public enum Route: Equatable {
        case appearance(AppearanceState)
        case language(LanguageState)
        case activate(ActivatePasscodeState)
        case menu(MenuPasscodeState)
        case camera(CameraState)
        case microphone(MicrophoneState)
        case export(ExportState)
        case agreements(AgreementsState)
        case about(AboutState)
    }
    
    var appearanceState: AppearanceState? {
        get {
            guard case let .appearance(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .appearance(newValue)
        }
    }
    var languageState: LanguageState? {
        get {
            guard case let .language(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .language(newValue)
        }
    }
    var activateState: ActivatePasscodeState? {
        get {
            guard case let .activate(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .activate(newValue)
        }
    }
    var menuState: MenuPasscodeState? {
        get {
            guard case let .menu(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .menu(newValue)
        }
    }
    var cameraState: CameraState? {
        get {
            guard case let .camera(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .camera(newValue)
        }
    }
    var microphoneState: MicrophoneState? {
        get {
            guard case let .microphone(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .microphone(newValue)
        }
    }
    var exportState: ExportState? {
        get {
            guard case let .export(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .export(newValue)
        }
    }
    var agreementsState: AgreementsState? {
        get {
            guard case let .agreements(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .agreements(newValue)
        }
    }
    var aboutState: AboutState? {
        get {
            guard case let .about(state) = self.route else { return nil }
            return state
        }
        set {
            guard let newValue = newValue else { return }
            self.route = .about(newValue)
        }
    }

    public var microphoneStatus: AVAudioSessionClient.AudioRecordPermission = .notDetermined
    
    public init(
        showSplash: Bool = false,
        styleType: StyleType,
        layoutType: LayoutType,
        themeType: ThemeType,
        iconType: IconAppType,
        hasPasscode: Bool,
        cameraStatus: AuthorizedVideoStatus,
        optionTimeForAskPasscode: Int
    ) {
        self.showSplash = showSplash
        self.styleType = styleType
        self.layoutType = layoutType
        self.themeType = themeType
        self.hasPasscode = hasPasscode
        self.iconAppType = iconType
        self.cameraStatus = cameraStatus
        self.optionTimeForAskPasscode = optionTimeForAskPasscode
    }
}
