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
    public func userDefaults() -> Reducer {
        return .init { state, action, environment in
            let effects = self.run(&state, action, environment)
            
            switch action {
            case let .featureAction(.home(.settings(.appearanceAction(.layoutAction(.layoutChanged(layout)))))):
                return .merge(
                    environment.userDefaultsClient.set(layoutType: layout)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.home(.settings(.appearanceAction(.styleAction(.styleChanged(style)))))):
                return .merge(
                    environment.userDefaultsClient.set(styleType: style)
                        .fireAndForget(),
                    effects
                )
            case let .featureAction(.home(.settings(.appearanceAction(.themeAction(.themeChanged(theme)))))):
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
            default:
                return effects
            }
        }
    }
}
