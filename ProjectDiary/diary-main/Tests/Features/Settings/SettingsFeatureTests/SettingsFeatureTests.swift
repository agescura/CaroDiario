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
        var setShowSplash = false
        var setStyleType = false
        var setLayoutType = false
        var setDarkAppIconType = false
        var setLightAppIconType = false
        var setThemeType = false
        
        let store = TestStore(
            initialState: SettingsState(
                showSplash: true,
                styleType: .rectangle,
                layoutType: .horizontal,
                themeType: .system,
                iconType: .light,
                hasPasscode: false,
                cameraStatus: .notDetermined,
                optionTimeForAskPasscode: nil
            ),
            reducer: settingsReducer,
            environment: SettingsEnvironment(
                coreDataClient: .noop,
                fileClient: .noop,
                userDefaultsClient: UserDefaultsClient(
                    boolForKey: { _ in false },
                    setBool: { value, key in
                        if key == "hideSplashScreenKey" && value == true {
                            setShowSplash = true
                        }
                        return .fireAndForget {}
                    },
                    stringForKey: { _ in nil },
                    setString: { value, key in
                        if key == "stringForStylingKey" && value == "Style.Rounded" {
                            setStyleType = true
                        }
                        if key == "stringForLayoutKey" && value == "Style.Vertical" {
                            setLayoutType = true
                        }
                        if key == "stringForThemeKey" && value == "Style.Dark" {
                            setThemeType = true
                        }
                        return .fireAndForget {}
                    },
                    intForKey: { _ in nil  },
                    setInt: { _, _  in .fireAndForget {} },
                    dateForKey: { _ in nil },
                    setDate: { _, _  in .fireAndForget {} },
                    remove: { _ in .fireAndForget {} }
                ),
                localAuthenticationClient: .noop,
                applicationClient: .init(
                    alternateIconName: nil,
                    setAlternateIconName: { value in
                        if value == "AppIcon-2" {
                            setDarkAppIconType = true
                        }
                        if value == nil {
                            setLightAppIconType = true
                        }
                        return .fireAndForget {}
                    },
                    supportsAlternateIcons: { true },
                    openSettings: { .fireAndForget {} },
                    open: { _ in .fireAndForget {} },
                    share: { _ in .fireAndForget {} }
                ),
                avCaptureDeviceClient: .noop,
                feedbackGeneratorClient: .noop,
                avAudioSessionClient: .noop,
                storeKitClient: .noop,
                pdfKitClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                mainRunLoop: .immediate,
                setUserInterfaceStyle: { _ in .fireAndForget {} }
                )
        )
        
        store.send(.toggleShowSplash(isOn: false)) {
            $0.showSplash = false
            XCTAssertTrue(setShowSplash)
        }
        
        store.send(.navigateAppearance(true)) {
            $0.appearanceState = .init(
                styleType: .rectangle,
                layoutType: .horizontal,
                themeType: .system,
                iconAppType: .light
            )
            $0.navigateAppearance = true
        }
        
        store.send(.navigateAppearance(false)) {
            $0.appearanceState = nil
            $0.navigateAppearance = false
        }
    }
}
