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
		
		await store.send(\.view.themeButtonTapped)
		await store.receive(\.delegate.navigateToTheme)
	}
	
	func testAlertSkipOnboarding() async {
		let store = TestStore(
			initialState: LayoutFeature.State(entries: fakeEntries),
			reducer: { LayoutFeature() }
		)
		
		await store.send(\.view.skipAlertButtonTapped) {
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
		
		await store.send(\.view.skipAlertButtonTapped) {
			$0.alert = .skip
		}
		await store.send(\.alert.dismiss) {
			$0.alert = nil
		}
	}
	
	func testSnapshot() {
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
			
			for language in Localizable.allCases {
				userSettings.language = language
				
				assertSnapshot(
					LayoutView(
						store: Store(
							initialState: LayoutFeature.State(entries: fakeEntries),
							reducer: {}
						)
					)
				)
				
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
	}
}
