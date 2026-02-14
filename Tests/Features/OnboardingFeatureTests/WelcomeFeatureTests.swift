import ComposableArchitecture
import Models
import SnapshotTesting
import SwiftUI
import TestHelper
import Testing

@testable import OnboardingFeature

@MainActor
@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct WelcomeFeatureTests {
	@Test
	func testHappyPath() async {
		let clock = TestClock()
		let store = TestStore(
			initialState: WelcomeFeature.State(),
			reducer: { WelcomeFeature() }
		) {
			$0.continuousClock = clock
		}
		
		await store.send(\.view.task)
		await clock.advance(by: .seconds(5))
		await store.receive(\.nextPage) {
			$0.selectedPage = 1
			$0.tabViewAnimated = true
		}
		await clock.advance(by: .seconds(5))
		await store.receive(.nextPage) {
			$0.selectedPage = 2
		}
		await store.send(\.view.privacyButtonTapped) {
			$0.path.append(.privacy(PrivacyFeature.State()))
		}
	}
	
	@Test
	func testSkipOnboarding() async {
		let clock = TestClock()
		let store = TestStore(
			initialState: WelcomeFeature.State(),
			reducer: { WelcomeFeature() }
		) {
			$0.continuousClock = clock
		}
		
		await store.send(\.view.task)
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
			initialState: WelcomeFeature.State(),
			reducer: { WelcomeFeature() }
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
					WelcomeView(
						store: Store(
							initialState: WelcomeFeature.State(),
							reducer: {}
						)
					)
				)
				
				assertSnapshot(
					WelcomeView(
						store: Store(
							initialState: WelcomeFeature.State(selectedPage: 1),
							reducer: {}
						)
					)
				)
				
				assertSnapshot(
					WelcomeView(
						store: Store(
							initialState: WelcomeFeature.State(selectedPage: 2),
							reducer: {}
						)
					)
				)
			}
		}
	}
}
