//
//  SearchFeatureTests.swift
//  
//
//  Created by Albert Gil Escura on 24/8/21.
//

import XCTest
import ComposableArchitecture
@testable import SearchFeature
import Models

class SearchFeatureTests: XCTestCase {
    
    func testHappyPath() {
        let store = TestStore(
            initialState: SearchState(searchText: "", entries: []),
            reducer: searchReducer,
            environment: SearchEnvironment(
                coreDataClient: .noop,
                fileClient: .noop,
                userDefaultsClient: .noop,
                avCaptureDeviceClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                avAssetClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                mainRunLoop: .immediate,
                uuid: UUID.init
            )
        )
        
        store.send(.searching(newText: "hello")) {
            $0.searchText = "hello"
        }
    }
    
}
