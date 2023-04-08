import XCTest
@testable import AppearanceFeature
import ComposableArchitecture
import EntriesFeature
import FeedbackGeneratorClient

@MainActor
class StyleViewTests: XCTestCase {
  
  func testStyleHappyPath() async {
    var selectionChangedCalled = false
    let store = TestStore(
      initialState: .init(
        styleType: .rectangle,
        layoutType: .horizontal,
        entries: []
      ),
      reducer: Style()
    )
    
    store.dependencies.feedbackGeneratorClient.selectionChanged = {
      selectionChangedCalled = true
    }
    
    await store.send(.styleChanged(.rounded)) {
      $0.styleType = .rounded
      $0.entries = fakeEntries(with: .rounded, layout: .horizontal)
      XCTAssertTrue(selectionChangedCalled)
      selectionChangedCalled = false
    }
    
    await store.send(.styleChanged(.rectangle)) {
      $0.styleType = .rectangle
      $0.entries = fakeEntries(with: .rectangle, layout: .horizontal)
      XCTAssertTrue(selectionChangedCalled)
    }
  }
  
  func testSnapshot() {
    SnapshotTesting.diffTool = "ksdiff"
    
    let store = Store(
      initialState: .init(
        styleType: .rectangle,
        layoutType: .horizontal,
        entries: fakeEntries(with: .rectangle, layout: .vertical)
      ),
      reducer: Style()
    )
    let view = StyleView(store: store)
    
    let vc = UIHostingController(rootView: view)
    vc.view.frame = UIScreen.main.bounds
    
    let viewStore = ViewStore(
      store.scope(state: { _ in () }),
      removeDuplicates: ==
    )
    
    assertSnapshot(matching: vc, as: .image)
    
    viewStore.send(.styleChanged(.rounded))
    assertSnapshot(matching: vc, as: .image)
    
    viewStore.send(.styleChanged(.rectangle))
    assertSnapshot(matching: vc, as: .image)
  }
}

import SnapshotTesting
import SwiftUI
