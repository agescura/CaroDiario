//
//  StyleViewTests.swift
//  
//
//  Created by Albert Gil Escura on 22/8/21.
//

import XCTest
@testable import AppearanceFeature
import ComposableArchitecture
import EntriesFeature

class StyleViewTests: XCTestCase {
    
    func testStyleHappyPath() {
        let store = TestStore(
            initialState: StyleState(styleType: .rectangle, layoutType: .horizontal, entries: []),
            reducer: styleReducer,
            environment: StyleEnvironment(
                feedbackGeneratorClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                date: Date.init
            )
        )
        
        store.send(.styleChanged(.rounded)) {
            $0.styleType = .rounded
            $0.entries = fakeEntries(with: .rounded, layout: .horizontal)
        }
    }
}
