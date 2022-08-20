//
//  SettingsFeatureTests.swift
//  
//
//  Created by Albert Gil Escura on 11/7/21.
//

import XCTest
@testable import SettingsFeature
import ComposableArchitecture
import SwiftUI
import UserDefaultsClient
import Styles

class SettingsFeatureTests: XCTestCase {
    
    func testSettingsHappyPath() {
        let store = TestStore(
            initialState: SettingsState(
                showSplash: true,
                styleType: .rectangle,
                layoutType: .horizontal,
                themeType: .system,
                iconType: .light,
                hasPasscode: false,
                cameraStatus: .notDetermined,
                optionTimeForAskPasscode: 0,
                faceIdEnabled: false,
                language: .spanish
            ),
            reducer: settingsReducer,
            environment: SettingsEnvironment(
                fileClient: .noop,
                localAuthenticationClient: .noop,
                applicationClient: .init(
                    alternateIconName: nil,
                    setAlternateIconName: { _ in
                        return .fireAndForget {}
                    },
                    supportsAlternateIcons: { true },
                    openSettings: { .fireAndForget {} },
                    open: { _, _  in .fireAndForget {} },
                    canOpen: { _ in true },
                    share: { _, _  in .fireAndForget {} },
                    showTabView: { _ in .fireAndForget {} }
                ),
                avCaptureDeviceClient: .noop,
                feedbackGeneratorClient: .noop,
                avAudioSessionClient: .noop,
                storeKitClient: .noop,
                pdfKitClient: .noop,
                mainQueue: .immediate,
                date: Date.init,
                setUserInterfaceStyle: { _ in .fireAndForget {} }
                )
        )
        
        store.send(.toggleShowSplash(isOn: false)) {
            $0.showSplash = false
        }
        
        store.send(.navigateAppearance(true)) {
            $0.route = .appearance(
                .init(
                    styleType: .rectangle,
                    layoutType: .horizontal,
                    themeType: .system,
                    iconAppType: .light
                )
            )
        }
        
        store.send(.navigateAppearance(false)) {
            $0.appearanceState = nil
            $0.route = nil
        }
    }
}
