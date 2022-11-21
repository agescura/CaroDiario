//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import Foundation
import ComposableArchitecture
import PasscodeFeature

extension Reducer where State == RootState, Action == RootAction, Environment == RootEnvironment {
    public func userDefaults() -> Reducer<RootState, RootAction, RootEnvironment> {
        return .init { state, action, environment in
            let effects = self.run(&state, action, environment)
            
            switch action {
            case let .featureAction(.home(.settings(.appearance(.layout(.layoutChanged(layout)))))):
                return .merge(
                    environment.userDefaultsClient.set(layoutType: layout)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.home(.settings(.appearance(.style(.styleChanged(style)))))):
                return .merge(
                    environment.userDefaultsClient.set(styleType: style)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.home(.settings(.appearance(.theme(.themeChanged(theme)))))):
                return .merge(
                    environment.userDefaultsClient.set(themeType: theme)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.home(.settings(.toggleShowSplash(isOn: isOn)))):
                return .merge(
                    environment.userDefaultsClient.setHideSplashScreen(!isOn)
                        .fireAndForget(),
                    effects
                )
            case .featureAction(.home(.settings(.activatePasscodeAction(.insertPasscodeAction(.menuPasscodeAction(.actionSheetTurnoffTapped)))))),
                    .featureAction(.home(.settings(.menuPasscodeAction(.actionSheetTurnoffTapped)))):
                return .merge(
                    environment.userDefaultsClient.removePasscode()
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.home(.settings(.activatePasscodeAction(.insertPasscodeAction(.update(code: code)))))):
                return .merge(
                    environment.userDefaultsClient.setPasscode(code)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.home(.settings(.menuPasscodeAction(.faceId(response: faceId))))),
                let .featureAction(.home(.settings(.activatePasscodeAction(.insertPasscodeAction(.menuPasscodeAction(.faceId(response: faceId))))))):
                return .merge(
                    environment.userDefaultsClient.setFaceIDActivate(faceId)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.home(.settings(.menuPasscodeAction(.optionTimeForAskPasscode(changed: newOption))))),
                let .featureAction(.home(.settings(.activatePasscodeAction(.insertPasscodeAction(.menuPasscodeAction(.optionTimeForAskPasscode(changed: newOption))))))):
                return .merge(
                    environment.userDefaultsClient.setOptionTimeForAskPasscode(newOption.value)
                        .fireAndForget(),
                    effects
                )
            case .featureAction(.home(.settings(.activatePasscodeAction(.insertPasscodeAction(.navigateMenuPasscode(true)))))):
                return .merge(
                    environment.userDefaultsClient.setOptionTimeForAskPasscode(TimeForAskPasscode.never.value)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.home(.settings(.languageAction(.updateLanguageTapped(language))))):
                return .merge(
                    environment.userDefaultsClient.setLanguage(language.rawValue)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.onBoarding(.privacy(.style(.styleChanged(styleChanged))))):
                return .merge(
                    environment.userDefaultsClient.set(styleType: styleChanged)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.onBoarding(.privacy(.style(.layout(.layoutChanged(layoutChanged)))))):
                return .merge(
                    environment.userDefaultsClient.set(layoutType: layoutChanged)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.onBoarding(.privacy(.style(.layout(.theme(.themeChanged(themeChanged))))))):
                return .merge(
                    environment.userDefaultsClient.set(themeType: themeChanged)
                        .fireAndForget(),
                    effects
                )
            default:
                return effects
            }
        }
    }
}
