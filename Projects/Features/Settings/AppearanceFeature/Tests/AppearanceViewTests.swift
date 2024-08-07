@testable import AppearanceFeature
import EntriesFeature
import ComposableArchitecture
import Models
import TestUtils
import XCTest

class AppearanceViewTests: XCTestCase {
	@MainActor
	func testHappyPath() async {
		let store = TestStore(
			initialState: AppearanceFeature.State(),
			reducer: { AppearanceFeature() }
		)
		
		await store.send(.iconAppButtonTapped)
		await store.receive(.delegate(.navigateToIconApp))
		
		await store.send(.layoutButtonTapped)
		await store.receive(.delegate(.navigateToLayout))
		
		await store.send(.styleButtonTapped)
		await store.receive(.delegate(.navigateToStyle))
		
		await store.send(.themeButtonTapped)
		await store.receive(.delegate(.navigateToTheme))
	}
}
