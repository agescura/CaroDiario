//
//  ThemeViewTests.swift
//  
//
//  Created by Albert Gil Escura on 22/8/21.
//

import XCTest
@testable import SettingsFeature
import ComposableArchitecture

class ThemeViewTests: XCTestCase {
    
    func testThemeHappyPath() {
        let store = TestStore(
            initialState: ThemeState(entries: []),
            reducer: themeReducer,
            environment: ThemeEnvironment(
                feedbackGeneratorClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                mainRunLoop: .immediate
            )
        )
        
        store.send(.themeChanged(.dark)) {
            $0.themeType = .dark
        }
    }
}
