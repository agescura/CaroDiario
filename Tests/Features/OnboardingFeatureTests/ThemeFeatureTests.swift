import XCTest
@testable import OnboardingFeature
import ComposableArchitecture
import SwiftUI
import EntriesFeature
import UserDefaultsClient

@MainActor
class ThemeFeatureTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: ThemeFeature.State(
				entries: fakeEntries,
				themeType: .system
			),
			reducer: ThemeFeature()
		) {
			$0.userDefaultsClient.objectForKey = { _ in nil }
		}
		
		await store.send(.finishButtonTapped)
		await store.receive(.delegate(.finished))
	}
}

