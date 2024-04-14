@testable import AppearanceFeature
import EntriesFeature
import ComposableArchitecture
import FeedbackGeneratorClient
import Models
import TestUtils
import XCTest

class LayoutViewTests: XCTestCase {
	@MainActor
  func testAppearanceHappyPath() async {
    let store = TestStore(
			initialState: LayoutFeature.State(entries: []),
			reducer: { LayoutFeature() }
		) {
			$0.feedbackGeneratorClient.selectionChanged = {}
		}
    
    await store.send(.layoutChanged(.vertical)) {
			$0.userSettings.appearance.layoutType = .vertical
      $0.entries = fakeEntries
    }
  }
	
	func testSnapshot() {
		assertSnapshot(
			LayoutView(
				store: Store(
					initialState: LayoutFeature.State(entries: fakeEntries),
					reducer: { }
				)
			)
		)
		
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
		userSettings.appearance.layoutType = .vertical
		
		assertSnapshot(
			LayoutView(
				store: Store(
					initialState: LayoutFeature.State(entries: fakeEntries),
					reducer: { }
				)
			)
		)
	}
}
