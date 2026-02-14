import ComposableArchitecture
import Models
import SnapshotTesting
import SwiftUI
import TestHelper
import Testing

@testable import OnboardingFeature

@MainActor
@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct PrivacyFeatureTests {
	@Test
	func testHappyPath() async {
		let store = TestStore(
			initialState: PrivacyFeature.State(),
			reducer: { PrivacyFeature() }
		)
		
		await store.send(\.view.styleButtonTapped)
		await store.receive(\.delegate.navigateToStyle)
	}
	
	@Test
	func testAlertSkipOnboarding() async {
		let store = TestStore(
			initialState: PrivacyFeature.State(),
			reducer: { PrivacyFeature() }
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
			initialState: PrivacyFeature.State(),
			reducer: { PrivacyFeature() }
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
					PrivacyView(
						store: Store(
							initialState: PrivacyFeature.State(),
							reducer: {}
						)
					)
				)
			}
		}
	}
}

