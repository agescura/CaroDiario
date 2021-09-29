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
import SharedModels

class HomeFeatureTests: XCTestCase {
    let scheduler = DispatchQueue.test
    
    func testAppScreenHappyPath() {
        let store = TestStore(
            initialState: HomeState(
                tabBars: [],
                entriesState: .init(entries: []),
                searchState: .init(searchText: "", entries: .init()),
                settings: .init(
                    styleType: .rectangle,
                    layoutType: .horizontal,
                    themeType: .dark,
                    iconType: .dark,
                    hasPasscode: false,
                    cameraStatus: .authorized,
                    optionTimeForAskPasscode: nil
                )
            ),
            reducer: homeReducer,
            environment: HomeEnvironment(
                coreDataClient: .noop,
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
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                mainRunLoop: .immediate,
                uuid: UUID.init,
                setUserInterfaceStyle: { _ in .fireAndForget {} }
            )
        )
        
        store.send(.entries(.onAppear))
        
            
    }
}
