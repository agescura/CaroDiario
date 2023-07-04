import XCTest
@testable import PasscodeFeature
import ComposableArchitecture
import SwiftUI

@MainActor
class MenuPasscodeViewTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: MenuPasscodeFeature.State(
				authenticationType: .none,
				optionTimeForAskPasscode: 0,
				faceIdEnabled: false
			),
			reducer: MenuPasscodeFeature()
		)
		
		await store.send(.confirmationDialogButtonTapped) {
			$0.confirmationDialog = .confirmationDialog(type: .none)
		}
	}
}
