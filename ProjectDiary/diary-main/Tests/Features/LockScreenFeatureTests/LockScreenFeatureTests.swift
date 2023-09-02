import XCTest
@testable import LockScreenFeature
import ComposableArchitecture
import SwiftUI

class LockScreenFeatureTests: XCTestCase {
    func testLockScreenHappyPath() {
        let store = TestStore(
            initialState: LockScreenState(code: "1111"),
            reducer: lockScreenReducer,
            environment: LockScreenEnvironment(
                userDefaultsClient: .noop,
                localAuthenticationClient: .noop,
                mainQueue: .immediate
            )
        )
        
        store.send(.numberButtonTapped(.number(1))) {
            $0.codeToMatch = "1"
        }
        store.send(.numberButtonTapped(.number(1))) {
            $0.codeToMatch = "11"
        }
        store.send(.numberButtonTapped(.number(1))) {
            $0.codeToMatch = "111"
        }
        store.send(.numberButtonTapped(.number(1))) {
            $0.codeToMatch = "1111"
        }
        store.receive(.matchedCode)
    }
    
    func testLockScreenFailed() {
        let store = TestStore(
            initialState: LockScreenState(code: "1111"),
            reducer: lockScreenReducer,
            environment: LockScreenEnvironment(
                userDefaultsClient: .noop,
                localAuthenticationClient: .noop,
                mainQueue: .immediate
            )
        )
        
        store.send(.numberButtonTapped(.number(1))) {
            $0.codeToMatch = "1"
        }
        store.send(.numberButtonTapped(.number(2))) {
            $0.codeToMatch = "12"
        }
        store.send(.numberButtonTapped(.number(3))) {
            $0.codeToMatch = "123"
        }
        store.send(.numberButtonTapped(.number(4))) {
            $0.codeToMatch = "1234"
        }
        store.receive(.failedCode) {
            $0.codeToMatch = ""
            $0.wrongAttempts = 4
        }
        store.receive(.reset) {
            $0.wrongAttempts = 0
        }
    }
}
