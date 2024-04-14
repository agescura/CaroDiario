import ComposableArchitecture
@testable import PasscodeFeature
import SwiftUI
import XCTest

@MainActor
class MenuPasscodeViewTests: XCTestCase {
	func happyPath() async {
		let store = TestStore(
			initialState: MenuFeature.State(),
			reducer: { MenuFeature() }
		)
		
//		await store.send(.)
	}
}
