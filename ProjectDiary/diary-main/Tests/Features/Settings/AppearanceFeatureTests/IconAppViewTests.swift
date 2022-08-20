//
//  IconAppViewTests.swift
//  
//
//  Created by Albert Gil Escura on 22/8/21.
//

import XCTest
@testable import AppearanceFeature
import ComposableArchitecture

class IconAppViewTests: XCTestCase {
    
    func testIconAppHappyPath() {
        var environment = IconAppEnvironment(
            feedbackGeneratorClient: .noop
        )
        var selectionChangedCalled = false
        environment.feedbackGeneratorClient.selectionChanged = {
            selectionChangedCalled = true
            return .fireAndForget {}
        }
        let store = TestStore(
            initialState: IconAppState(iconAppType: .light),
            reducer: iconAppReducer,
            environment: environment
        )
        
        store.send(.iconAppChanged(.dark)) {
            $0.iconAppType = .dark
            XCTAssertTrue(selectionChangedCalled)
            selectionChangedCalled = false
        }
        
        store.send(.iconAppChanged(.light)) {
            $0.iconAppType = .light
            XCTAssertTrue(selectionChangedCalled)
        }
    }
    
    func testSnapshot() {
        let store = Store(
            initialState: .init(iconAppType: .light),
            reducer: iconAppReducer,
            environment: .init(feedbackGeneratorClient: .noop)
        )
        let view = IconAppView(store: store)
        
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        
        let viewStore = ViewStore(
            store.scope(state: { _ in () }),
            removeDuplicates: ==
        )
        
        assertSnapshot(matching: vc, as: .image)
        
        viewStore.send(.iconAppChanged(.dark))
        assertSnapshot(matching: vc, as: .image)
        
        viewStore.send(.iconAppChanged(.light))
        assertSnapshot(matching: vc, as: .image)
    }
}

import SwiftUI
import SnapshotTesting
