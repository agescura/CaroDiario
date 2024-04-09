import ComposableArchitecture
@testable import OnboardingFeature
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

@MainActor
class WelcomeFeatureTests: XCTestCase {
	func testHappyPath() async {
		let clock = TestClock()
		let store = TestStore(
			initialState: WelcomeFeature.State(),
			reducer: { WelcomeFeature() }
		) {
			$0.continuousClock = clock
		}
		
		await store.send(\.task)
		await clock.advance(by: .seconds(5))
		await store.receive(\.nextPage) {
			$0.selectedPage = 1
			$0.tabViewAnimated = true
		}
		await clock.advance(by: .seconds(5))
		await store.receive(.nextPage) {
			$0.selectedPage = 2
		}
		await store.send(\.privacyButtonTapped) {
			$0.path.append(.privacy(PrivacyFeature.State()))
		}
	}
	
	func testSkipOnboarding() async {
		let clock = TestClock()
		let store = TestStore(
			initialState: WelcomeFeature.State(),
			reducer: { WelcomeFeature() }
		) {
			$0.continuousClock = clock
		}
		
		await store.send(\.task)
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
			initialState: WelcomeFeature.State(),
			reducer: { WelcomeFeature() }
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
