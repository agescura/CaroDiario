import ComposableArchitecture
import EntriesFeature
@testable import OnboardingFeature
import SwiftUI
import XCTest

@MainActor
class ThemeFeatureTests: XCTestCase {
	func testHappyPath() async {
		var setBoolCalled = (false, "")
		let store = TestStore(
			initialState: ThemeFeature.State(
				themeType: .system,
				entries: fakeEntries(
					with: .rectangle,
					layout: .horizontal
				)
			),
			reducer: ThemeFeature.init
		) {
			$0.userDefaultsClient.setBool = { setBoolCalled = ($0, $1) }
		}
		
		await store.send(.startButtonTapped)
		
		XCTAssertEqual(setBoolCalled.0, true)
		XCTAssertEqual(setBoolCalled.1, "hasShownOnboardingKey")
	}
}
