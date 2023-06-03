import XCTest
@testable import AppearanceFeature
import ComposableArchitecture
import FeedbackGeneratorClient
import EntriesFeature

@MainActor
class LayoutViewTests: XCTestCase {
  
  func testAppearanceHappyPath() async {
    var selectionChangedCalled = false
    
    let store = TestStore(
      initialState: .init(
        layoutType: .horizontal,
        styleType: .rectangle,
        entries: []
      ),
      reducer: LayoutFeature()
    )
    
    store.dependencies.feedbackGeneratorClient.selectionChanged = {
      selectionChangedCalled = true
    }
    
    await store.send(.layoutChanged(.vertical)) {
      $0.layoutType = .vertical
      XCTAssertTrue(selectionChangedCalled)
      $0.entries = fakeEntries(with: .rectangle, layout: .vertical)
    }
  }
}
