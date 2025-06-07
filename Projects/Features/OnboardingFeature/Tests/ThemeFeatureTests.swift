import ComposableArchitecture
import EntriesFeature
import Models
import SnapshotTesting
import SwiftUI
import Testing
import TestUtils

@testable import OnboardingFeature

@MainActor
struct ThemeFeatureTests {
	@Test
	func testHappyPath() async {
		let store = TestStore(
			initialState: ThemeFeature.State(entries: fakeEntries),
			reducer: { ThemeFeature() }
		)
		
		await store.send(\.view.startButtonTapped) {
			$0.$userSettings.hasShownOnboarding.withLock { $0 = true }
		}
		await store.receive(\.delegate.navigateToHome)
	}
	
	@Test
	func testSnapshot() {
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
			
			for language in Localizable.allCases {
				$userSettings.language.withLock { $0 = language }
				
				assertSnapshot(
					ThemeView(
						store: Store(
							initialState: ThemeFeature.State(entries: fakeEntries),
							reducer: {}
						)
					)
				)
			}
		}
	}
}
