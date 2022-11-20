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
        var environment = StyleEnvironment(
            feedbackGeneratorClient: .noop
        )
        var selectionChangedCalled = false
        environment.feedbackGeneratorClient.selectionChanged = {
            selectionChangedCalled = true
        }
        let store = TestStore(
            initialState: StyleState(styleType: .rectangle, layoutType: .horizontal, entries: []),
            reducer: styleReducer,
            environment: environment
        )
        
        store.send(.styleChanged(.rounded)) {
            $0.styleType = .rounded
            $0.entries = fakeEntries(with: .rounded, layout: .horizontal)
            XCTAssertTrue(selectionChangedCalled)
            selectionChangedCalled = false
        }
        
        store.send(.styleChanged(.rectangle)) {
            $0.styleType = .rectangle
            $0.entries = fakeEntries(with: .rectangle, layout: .horizontal)
            XCTAssertTrue(selectionChangedCalled)
        }
    }
    
    func testSnapshot() {
        let store = Store(
            initialState: .init(
                styleType: .rectangle,
                layoutType: .horizontal,
                entries: fakeEntries(with: .rectangle, layout: .vertical)
            ),
            reducer: styleReducer,
            environment: .init(feedbackGeneratorClient: .noop)
        )
        let view = StyleView(store: store)
        
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        
        let viewStore = ViewStore(
            store.scope(state: { _ in () }),
            removeDuplicates: ==
        )
        
        assertSnapshot(matching: vc, as: .image)
        
        viewStore.send(.styleChanged(.rounded))
        assertSnapshot(matching: vc, as: .image)
        
        viewStore.send(.styleChanged(.rectangle))
        assertSnapshot(matching: vc, as: .image)
    }
}

import SnapshotTesting
import SwiftUI
