//
//  ThemeViewTests.swift
//  
//
//  Created by Albert Gil Escura on 22/8/21.
//

import XCTest
@testable import AppearanceFeature
import ComposableArchitecture
import EntriesFeature

@MainActor
class ThemeViewTests: XCTestCase {
    
    func testThemeHappyPath() async {
        var environment = ThemeEnvironment(
          feedbackGeneratorClient: .noop
        )
        var selectionChangedCalled = false
        environment.feedbackGeneratorClient.selectionChanged = {
            selectionChangedCalled = true
        }
        let store = TestStore(
            initialState: ThemeState(entries: []),
            reducer: themeReducer,
            environment: environment
        )
        
        await store.send(.themeChanged(.dark)) {
            $0.themeType = .dark
            XCTAssertTrue(selectionChangedCalled)
            selectionChangedCalled = false
        }
        
        await store.send(.themeChanged(.light)) {
            $0.themeType = .light
            XCTAssertTrue(selectionChangedCalled)
        }
    }
    
    func testSnapshot() {
        let store = Store(
            initialState: .init(
                entries: fakeEntries(with: .rectangle, layout: .vertical)
            ),
            reducer: themeReducer,
            environment: .init(
              feedbackGeneratorClient: .noop
            )
        )
        let view = ThemeView(store: store)
        
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        
        let viewStore = ViewStore(
            store.scope(state: { _ in () }),
            removeDuplicates: ==
        )
        
        assertSnapshot(matching: vc, as: .image)
        
        viewStore.send(.themeChanged(.dark))
        assertSnapshot(matching: vc, as: .image)
        
        viewStore.send(.themeChanged(.light))
        assertSnapshot(matching: vc, as: .image)
    }
}

import SnapshotTesting
import SwiftUI
