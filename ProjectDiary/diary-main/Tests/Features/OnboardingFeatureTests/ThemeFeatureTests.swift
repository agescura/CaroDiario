import ComposableArchitecture
import EntriesFeature
import Models
@testable import OnboardingFeature
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

@MainActor
class ThemeFeatureTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: ThemeFeature.State(entries: fakeEntries),
			reducer: { ThemeFeature() }
		)
		
		await store.send(\.startButtonTapped) {
			$0.userSettings.hasShownOnboarding = true
		}
		await store.receive(\.delegate.navigateToHome)
	}
}
