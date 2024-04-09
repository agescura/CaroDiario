import ComposableArchitecture
import EntriesFeature
import Models
@testable import OnboardingFeature
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

@MainActor
class StyleOnboardingViewTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: StyleFeature.State(entries: fakeEntries),
			reducer: { StyleFeature() }
		)
		
		await store.send(.styleChanged(.rounded)) {
			$0.entries[0].dayEntries.style = .rounded
			$0.userSettings.appearance.styleType = .rounded
		}
		
		await store.send(\.layoutButtonTapped)
		await store.receive(\.delegate.navigateToLayout)
	}
	
	func testAlertSkipOnboarding() async {
		let store = TestStore(
			initialState: StyleFeature.State(entries: fakeEntries),
			reducer: { StyleFeature() }
		)
		
		await store.send(\.skipAlertButtonTapped) {
			$0.alert = .skip
		}
		await store.send(\.alert.skip) {
			$0.alert = nil
			$0.userSettings.hasShownOnboarding = true
		}
		await store.receive(\.delegate.navigateToHome)
	}
	
	func testAlertSkipCancel() async {
		let store = TestStore(
			initialState: StyleFeature.State(entries: fakeEntries),
			reducer: { StyleFeature() }
		)
		
		await store.send(\.skipAlertButtonTapped) {
			$0.alert = .skip
		}
		await store.send(\.alert.dismiss) {
			$0.alert = nil
		}
	}
	
	func testSnapshot() {
		assertSnapshot(
			StyleView(
				store: Store(
					initialState: StyleFeature.State(entries: fakeEntries),
					reducer: {}
				)
			)
		)
		
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
		userSettings.appearance.styleType = .rounded
		
		assertSnapshot(
			StyleView(
				store: Store(
					initialState: StyleFeature.State(entries: fakeEntries),
					reducer: {}
				)
			)
		)
	}
}
