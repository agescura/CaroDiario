import ComposableArchitecture
import EntriesFeature
import Models
import SnapshotTesting
import SwiftUI
import Testing
import TestUtils

@testable import OnboardingFeature

@MainActor
struct LayoutFeatureTests {
	@Test
	func testHappyPath() async {
		let store = TestStore(
			initialState: LayoutFeature.State(entries: fakeEntries),
			reducer: { LayoutFeature() }
		)
		
		await store.send(\.view.themeButtonTapped)
		await store.receive(\.delegate.navigateToTheme)
	}
	
	@Test
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
			$0.$userSettings.hasShownOnboarding.withLock { $0 = true }
		}
		await store.receive(\.delegate.navigateToHome)
	}
	
	@Test
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
	
	@Test
	func testSnapshot() {
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
			
			for language in Localizable.allCases {
				$userSettings.language.withLock { $0 = language }
				
				assertSnapshot(
					LayoutView(
						store: Store(
							initialState: LayoutFeature.State(entries: fakeEntries),
							reducer: {}
						)
					)
				)
				
				$userSettings.appearance.layoutType.withLock { $0 = .vertical }
				
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
