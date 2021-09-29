//
//  AppearanceViewTests.swift
//  
//
//  Created by Albert Gil Escura on 22/8/21.
//

import XCTest
@testable import SettingsFeature
import ComposableArchitecture
import FeedbackGeneratorClient
import EntriesFeature

class AppearanceViewTests: XCTestCase {
    
    func testAppearanceHappyPath() {
        var feedbackGeneratorCalled = false
        
        let store = TestStore(
            initialState: LayoutState(layoutType: .horizontal, styleType: .rectangle, entries: []),
            reducer: layoutReducer,
            environment: LayoutEnvironment(
                feedbackGeneratorClient: .init(
                    prepare: { .fireAndForget {} },
                    selectionChanged: {
                        feedbackGeneratorCalled = true
                        return .fireAndForget {}
                    }
                ),
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                mainRunLoop: .immediate
            )
        )
        
        store.send(.layoutChanged(.vertical)) {
            $0.layoutType = .vertical
            XCTAssertTrue(feedbackGeneratorCalled)
            $0.entries = fakeEntries(with: .rectangle, layout: .vertical)
        }
    }
}
