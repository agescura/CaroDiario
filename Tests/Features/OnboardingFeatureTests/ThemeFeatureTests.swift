import ComposableArchitecture
import Models
import SnapshotTesting
import SwiftUI
import TestHelper
import Testing

@testable import OnboardingFeature

@MainActor
@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct ThemeFeatureTests {
	@Test
	func testHappyPath() async {
		let store = TestStore(
			initialState: ThemeFeature.State(),
			reducer: { ThemeFeature() }
		)
		
		await store.send(\.view.startButtonTapped) {
			$0.$userSettings.hasShownOnboarding.withLock { $0 = true }
		}
		await store.receive(\.delegate.navigateToHome)
	}
	
	@Test
	func testSnapshot() {
    @Shared(.userSettings) var userSettings: UserSettings = .defaultValue
    
    for language in Localizable.allCases {
      $userSettings.language.withLock { $0 = language }
      
      assertSnapshot(
        ThemeView(
          store: Store(
            initialState: ThemeFeature.State(),
            reducer: {}
          )
        )
      )
    }
	}
}
