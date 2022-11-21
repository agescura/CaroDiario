//
//  HomeFeatureTests.swift
//  
//
//  Created by Albert Gil Escura on 11/7/21.
//

import XCTest
@testable import HomeFeature
import ComposableArchitecture
import SwiftUI
import Models

class HomeFeatureTests: XCTestCase {
    let scheduler = DispatchQueue.test
    
    func testAppScreenHappyPath() {
        let store = TestStore(
            initialState: .init(
                tabBars: [],
                sharedState: .init(
                    showSplash: false,
                    styleType: .rectangle,
                    layoutType: .horizontal,
                    themeType: .dark,
                    iconAppType: .dark,
                    language: .spanish,
                    hasPasscode: false,
                    cameraStatus: .authorized,
                    microphoneStatus: .authorized,
                    optionTimeForAskPasscode: 0,
                    faceIdEnabled: false
                )
            ),
            reducer: homeReducer,
            environment: HomeEnvironment(
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
                uuid: UUID.init
            )
        )
        
        store.send(.entries(.onAppear))
    }
}
