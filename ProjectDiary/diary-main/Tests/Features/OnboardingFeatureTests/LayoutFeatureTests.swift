import ComposableArchitecture
import EntriesFeature
import Models
@testable import OnboardingFeature
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

@MainActor
class LayoutFeatureTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: LayoutFeature.State(entries: fakeEntries),
			reducer: { LayoutFeature() }
		)
		
		await store.send(\.themeButtonTapped)
		await store.receive(\.delegate.navigateToTheme)
	}
	
	func testAlertSkipOnboarding() async {
		let store = TestStore(
			initialState: LayoutFeature.State(entries: fakeEntries),
			reducer: { LayoutFeature() }
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
			initialState: LayoutFeature.State(entries: fakeEntries),
			reducer: { LayoutFeature() }
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
			LayoutView(
				store: Store(
					initialState: LayoutFeature.State(entries: fakeEntries),
					reducer: {}
				)
			)
		)
		
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
		userSettings.appearance.layoutType = .vertical
		
		assertSnapshot(
			LayoutView(
				store: Store(
					initialState: LayoutFeature.State(entries: fakeEntries),
					reducer: {}
				)
			)
		)
	}
}
