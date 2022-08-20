//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import XCTest
@testable import PasscodeFeature
import ComposableArchitecture
import SwiftUI

class ActivatePasscodeViewTests: XCTestCase {
    func test() {
        let store = TestStore(
            initialState: ActivatePasscodeState(faceIdEnabled: false, hasPasscode: false),
            reducer: activatePasscodeReducer,
            environment: ActivatePasscodeEnvironment(
                userDefaultsClient: .noop,
                localAuthenticationClient: .noop,
                mainQueue: .unimplemented
            )
        )
        
        store.send(.actionSheetTurnoffTapped)
    }
}
