//
//  SplashFeatureTests.swift
//  SplashFeatureTests
//
//  Created by Albert Gil Escura on 26/6/21.
//

import XCTest
@testable import SplashFeature
import ComposableArchitecture
import SwiftUI

class SplashFeatureTests: XCTestCase {
    func testSplashScreenHappyPath() {
        let store = TestStore(
            initialState: SplashState(),
            reducer: splashReducer,
            environment: SplashEnvironment(
                userDefaultsClient: .noop,
                mainQueue: .immediate
            )
        )
        
        store.send(.startAnimation)
        store.receive(.verticalLineAnimation) {
            $0.animation = .verticalLine
        }
        store.receive(.areaAnimation) {
            $0.animation = .horizontalArea
        }
        store.receive(.finishAnimation) {
            $0.animation = .finish
        }
    }
}
