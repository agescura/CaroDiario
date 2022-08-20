//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import XCTest
@testable import AgreementsFeature
import ComposableArchitecture
import SwiftUI

class AgreementsFeatureTests: XCTestCase {
    func testOpenComposableArchitecture() {
        var environment = AgreementsEnvironment(applicationClient: .noop)
        environment.applicationClient.open = { url, _ in
            XCTAssertEqual(url.absoluteString, "https://github.com/pointfreeco/swift-composable-architecture")
            return .fireAndForget {}
        }
        let store = TestStore(
            initialState: AgreementsState(),
            reducer: agreementsReducer,
            environment: environment
        )
        
        store.send(.open(.composableArchitecture))
    }
    
    func testOpenRayWenderlich() {
        var environment = AgreementsEnvironment(applicationClient: .noop)
        environment.applicationClient.open = { url, _ in
            XCTAssertEqual(url.absoluteString, "https://www.raywenderlich.com/")
            return .fireAndForget {}
        }
        let store = TestStore(
            initialState: AgreementsState(),
            reducer: agreementsReducer,
            environment: environment
        )
        
        store.send(.open(.raywenderlich))
    }
    
    func testOpenPointfree() {
        var environment = AgreementsEnvironment(applicationClient: .noop)
        environment.applicationClient.open = { url, _ in
            XCTAssertEqual(url.absoluteString, "https://www.pointfree.co/")
            return .fireAndForget {}
        }
        let store = TestStore(
            initialState: AgreementsState(),
            reducer: agreementsReducer,
            environment: environment
        )
        
        store.send(.open(.pointfree))
    }
    
    func testSnapshot() {
        let view = AgreementsView(
            store: .init(
                initialState: .init(),
                reducer: agreementsReducer,
                environment: .init(applicationClient: .noop)
            )
        )
        
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(matching: vc, as: .image)
    }
}

import SnapshotTesting
