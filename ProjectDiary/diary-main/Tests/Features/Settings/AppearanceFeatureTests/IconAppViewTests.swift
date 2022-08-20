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
        let store = TestStore(
            initialState: IconAppState(iconAppType: .light),
            reducer: iconAppReducer,
            environment: IconAppEnvironment(
                feedbackGeneratorClient: .noop
            )
        )
        
        store.send(.iconAppChanged(.dark)) {
            $0.iconAppType = .dark
        }
    }
}
