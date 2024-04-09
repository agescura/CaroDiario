//
//  RootFeatureTests.swift
//  
//
//  Created by Albert Gil Escura on 16/7/21.
//

import XCTest
@testable import RootFeature
import ComposableArchitecture
import SwiftUI
import UserDefaultsClient
import EntriesFeature

@MainActor
class RootFeatureTests: XCTestCase {
    func testOpeningFirstTime() async {
        var setBoolCalled = false
        let emptyUserDefaultsClient = UserDefaultsClient(
            boolForKey: { _ in false },
            setBool: { value, key in
                if key == "hasShownOnboardingKey", value {
                    setBoolCalled = true
                }
                return .none
            },
            stringForKey: { _ in nil },
            setString: { _, _ in .none },
            intForKey: { _ in nil },
            setInt: { _, _ in .fireAndForget {}},
            dateForKey: { _ in nil },
            setDate: { _, _ in .fireAndForget {} },
            remove: { _ in .fireAndForget {} }
        )

        let store = TestStore(
            initialState: RootState(
                appDelegate: .init(),
                featureState: .splash(.init())
            ),
            reducer: rootReducer,
            environment: RootEnvironment(
                coreDataClient: .noop,
                fileClient: .noop,
                userDefaultsClient: emptyUserDefaultsClient,
                localAuthenticationClient: .noop,
                applicationClient: .noop,
                avCaptureDeviceClient: .noop,
                feedbackGeneratorClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                storeKitClient: .noop,
                pdfKitClient: .noop,
                avAssetClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                date: Date.init,
                uuid: UUID.init
            )
        )
        
        await store.send(.appDelegate(.didFinishLaunching))
        await store.receive(.setUserInterfaceStyle)
        await store.receive(.startFirstScreen)
        await store.receive(.featureAction(.splash(.startAnimation)))
        await store.receive(.featureAction(.splash(.verticalLineAnimation))) {
            $0.featureState = .splash(.init(animation: .verticalLine))
        }
        await store.receive(.featureAction(.splash(.areaAnimation))) {
            $0.featureState = .splash(.init(animation: .horizontalArea))
        }
        await store.receive(.featureAction(.splash(.finishAnimation))) {
            $0.featureState = .onBoarding(.init())
        }
    }
    
    func testReopeningWithSplashEnabled() async {
        let emptyUserDefaultsClient = UserDefaultsClient(
            boolForKey: { key in
                if key == "hasShownOnboardingKey" {
                    return true
                }
                return false
            },
            setBool: { _, _ in .none },
            stringForKey: { _ in nil },
            setString: { _, _ in .none },
            intForKey: { _ in nil },
            setInt: { _, _ in .fireAndForget {}},
            dateForKey: { _ in nil },
            setDate: { _, _ in .fireAndForget {} },
            remove: { _ in .fireAndForget {} }
        )
        let store = TestStore(
            initialState: RootState(
                appDelegate: .init(),
                featureState: .splash(.init())
            ),
            reducer: rootReducer,
            environment: RootEnvironment(
                coreDataClient: .noop,
                fileClient: .noop,
                userDefaultsClient: emptyUserDefaultsClient,
                localAuthenticationClient: .noop,
                applicationClient: .noop,
                avCaptureDeviceClient: .noop,
                feedbackGeneratorClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                storeKitClient: .noop,
                pdfKitClient: .noop,
                avAssetClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                date: Date.init,
                uuid: UUID.init
            )
        )
        
        await store.send(.appDelegate(.didFinishLaunching))
        await store.receive(.setUserInterfaceStyle)
        await store.receive(.startFirstScreen)
        await store.receive(.featureAction(.splash(.startAnimation)))
        await store.receive(.featureAction(.splash(.verticalLineAnimation))) {
            $0.featureState = .splash(.init(animation: .verticalLine))
        }
        await store.receive(.featureAction(.splash(.areaAnimation))) {
            $0.featureState = .splash(.init(animation: .horizontalArea))
        }
        await store.receive(.featureAction(.splash(.finishAnimation))) {
            $0.featureState = .splash(.init(animation: .finish))
        }
    }
    
    func testReopeningAppWithSplashDisabled() async {
        let emptyUserDefaultsClient = UserDefaultsClient(
            boolForKey: { key in
                if key == "hasShownOnboardingKey" {
                    return true
                }
                if key == "hideSplashScreenKey" {
                    return true
                }
                return false
            },
            setBool: { _, _ in .none },
            stringForKey: { _ in nil },
            setString: { _, _ in .none },
            intForKey: { _ in nil },
            setInt: { _, _ in .fireAndForget {}},
            dateForKey: { _ in nil },
            setDate: { _, _ in .fireAndForget {} },
            remove: { _ in .fireAndForget {} }
        )
        let store = TestStore(
            initialState: RootState(
                appDelegate: .init(),
                featureState: .splash(.init())
            ),
            reducer: rootReducer,
            environment: RootEnvironment(
                coreDataClient: .noop,
                fileClient: .noop,
                userDefaultsClient: emptyUserDefaultsClient,
                localAuthenticationClient: .noop,
                applicationClient: .noop,
                avCaptureDeviceClient: .noop,
                feedbackGeneratorClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                storeKitClient: .noop,
                pdfKitClient: .noop,
                avAssetClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                date: Date.init,
                uuid: UUID.init
            )
        )
        
        await store.send(.appDelegate(.didFinishLaunching))
        await store.receive(.setUserInterfaceStyle)
        await store.receive(.startFirstScreen)
    }
}
