import ComposableArchitecture
import Dependencies
import Models
@testable import OnboardingFeature
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

@MainActor
class WelcomeFeatureTests: XCTestCase {
	@MainActor
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
	
	@MainActor
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
			$0.userSettings.hasShownOnboarding = true
		}
		await store.receive(\.delegate.navigateToHome)
	}
	
	@MainActor
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
	
	func testSnapshot() {
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
			
			for language in Localizable.allCases {
				userSettings.language = language
				
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
