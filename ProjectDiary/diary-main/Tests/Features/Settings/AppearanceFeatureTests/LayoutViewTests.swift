import XCTest
@testable import AppearanceFeature
import ComposableArchitecture
import FeedbackGeneratorClient
import EntriesFeature

@MainActor
class LayoutViewTests: XCTestCase {
  
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
}
