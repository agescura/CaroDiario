import XCTest
@testable import PasscodeFeature
import ComposableArchitecture
import SwiftUI

class MenuPasscodeViewTests: XCTestCase {
    func test() {
        let store = TestStore(
            initialState: MenuPasscodeState(authenticationType: .none, optionTimeForAskPasscode: 0),
            reducer: menuPasscodeReducer,
            environment: MenuPasscodeEnvironment(
                userDefaultsClient: .noop,
                localAuthenticationClient: .noop,
                mainQueue: .immediate
            )
        )
        
        store.send(.actionSheetTurnoffTapped)
    }
}
