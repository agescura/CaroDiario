import ComposableArchitecture
@testable import OnboardingFeature
import SnapshotTesting
import SwiftUI
import TestUtils
import UserDefaultsClient
import XCTest

@MainActor
class PrivacyOnboardingViewTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: PrivacyFeature.State(),
			reducer: { PrivacyFeature() }
		)
		
		await store.send(\.styleButtonTapped)
		await store.receive(\.delegate.navigateToStyle)
	}
	
	func testAlertSkipOnboarding() async {
		let store = TestStore(
			initialState: PrivacyFeature.State(),
			reducer: { PrivacyFeature() }
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
			initialState: PrivacyFeature.State(),
			reducer: { PrivacyFeature() }
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
			PrivacyView(
				store: Store(
					initialState: PrivacyFeature.State(),
					reducer: {}
				)
			)
		)
	}
}

