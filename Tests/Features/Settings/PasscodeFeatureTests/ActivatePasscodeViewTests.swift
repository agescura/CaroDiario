import XCTest
@testable import PasscodeFeature
import ComposableArchitecture
import SwiftUI

@MainActor
class ActivatePasscodeViewTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: ActivateFeature.State(
				faceIdEnabled: false,
				hasPasscode: false
			),
			reducer: ActivateFeature()
		)
		
		await store.send(.navigateToInsert) {
			$0.insert = InsertFeature.State(
				faceIdEnabled: false
			)
		}
	}
}
