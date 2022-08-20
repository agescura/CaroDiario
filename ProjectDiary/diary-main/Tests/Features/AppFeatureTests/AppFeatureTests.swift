//
//  AppFeatureTests.swift
//  
//
//  Created by Albert Gil Escura on 11/7/21.
//

import XCTest
@testable import AppFeature
import ComposableArchitecture
import SwiftUI

class AppFeatureTests: XCTestCase {
    let scheduler = DispatchQueue.test
    
    func testAppScreenRunningSplashFeature() {
        let store = TestStore(
            initialState: .splash(.init()),
            reducer: appReducer,
            environment: AppEnvironment(
                fileClient: .noop,
                userDefaultsClient: .noop,
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
                uuid: UUID.init,
                setUserInterfaceStyle: { _ in .fireAndForget {} }
            )
        )
        
        store.send(.splash(.startAnimation))
        store.receive(.splash(.verticalLineAnimation)) {
            $0 = .splash(.init(animation: .verticalLine))
        }
        store.receive(.splash(.areaAnimation)) {
            $0 = .splash(.init(animation: .horizontalArea))
        }
        store.receive(.splash(.finishAnimation)) {
            $0 = .splash(.init(animation: .finish))
        }
    }
    
    func testAppScreenRunningOnBoardingFeature() {
        let store = TestStore(
            initialState: .onBoarding(.init()),
            reducer: appReducer,
            environment: AppEnvironment(
                fileClient: .noop,
                userDefaultsClient: .noop,
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
                uuid: UUID.init,
                setUserInterfaceStyle: { _ in .fireAndForget {} }
            )
        )
        
        store.send(.onBoarding(.navigationPrivacyOnBoarding(true))) {
            $0 = .onBoarding(
                .init(
                    privacyOnBoardingState: .init(),
                    navigatePrivacyOnBoarding: true
                )
            )
        }
    }
    
    func testAppScreenRunningHomeFeature() {
        let store = TestStore(
            initialState: .home(
                .init(
                    tabBars: [.entries, .settings],
                    entriesState: .init(entries: []),
                    searchState: .init(searchText: "", entries: .init()),
                    settings: .init(
                        styleType: .rectangle,
                        layoutType: .horizontal,
                        themeType: .dark,
                        iconType: .dark,
                        hasPasscode: false,
                        cameraStatus: .authorized,
                        optionTimeForAskPasscode: 0,
                        faceIdEnabled: false,
                        language: .spanish
                    )
                )
            ),
            reducer: appReducer,
            environment: AppEnvironment(
                fileClient: .noop,
                userDefaultsClient: .noop,
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
                uuid: UUID.init,
                setUserInterfaceStyle: { _ in .fireAndForget {} }
            )
        )
        
        store.send(.home(.starting))
    }
}
