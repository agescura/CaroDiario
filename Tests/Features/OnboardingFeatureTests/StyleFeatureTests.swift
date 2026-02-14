import ComposableArchitecture
import Models
import SnapshotTesting
import SwiftUI
import TestHelper
import Testing

@testable import OnboardingFeature

@MainActor
@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct StyleFeatureTests {
	@Test
	func testHappyPath() async {
		let store = TestStore(
			initialState: StyleFeature.State(),
			reducer: { StyleFeature() }
		)
		
		await store.send(.styleChanged(.rounded)) {
			$0.$userSettings.appearance.styleType.withLock { $0 = .rounded }
		}
		
		await store.send(\.view.layoutButtonTapped)
		await store.receive(\.delegate.navigateToLayout)
	}
	
	@Test
	func testAlertSkipOnboarding() async {
		let store = TestStore(
			initialState: StyleFeature.State(),
			reducer: { StyleFeature() }
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
			initialState: StyleFeature.State(),
			reducer: { StyleFeature() }
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
    @Shared(.userSettings) var userSettings: UserSettings = .defaultValue
    
    for language in Localizable.allCases {
      $userSettings.language.withLock { $0 = language }
      
      assertSnapshot(
        StyleView(
          store: Store(
            initialState: StyleFeature.State(),
            reducer: {}
          )
        )
      )
      
      $userSettings.appearance.styleType.withLock { $0 = .rounded }
      
      assertSnapshot(
        StyleView(
          store: Store(
            initialState: StyleFeature.State(),
            reducer: {}
          )
        )
      )
      
      $userSettings.appearance.styleType.withLock { $0 = .rectangle }
    }
	}
}
