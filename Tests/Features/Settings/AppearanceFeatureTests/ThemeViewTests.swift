import XCTest
@testable import AppearanceFeature
import ComposableArchitecture
import EntriesFeature

@MainActor
class ThemeViewTests: XCTestCase {
  
  func testThemeHappyPath() async {
    var selectionChangedCalled = false
    let store = TestStore(
      initialState: .init(entries: []),
      reducer: ThemeFeature()
    )

    store.dependencies.feedbackGeneratorClient.selectionChanged = {
      selectionChangedCalled = true
    }
    
    await store.send(.themeChanged(.dark)) {
      $0.themeType = .dark
      XCTAssertTrue(selectionChangedCalled)
      selectionChangedCalled = false
    }
    
    await store.send(.themeChanged(.light)) {
      $0.themeType = .light
      XCTAssertTrue(selectionChangedCalled)
    }
  }
  
  func testSnapshot() {
    SnapshotTesting.diffTool = "ksdiff"
    
    let store = Store(
      initialState: .init(
        entries: fakeEntries(with: .rectangle, layout: .vertical)
      ),
      reducer: ThemeFeature()
    )
    let view = ThemeView(store: store)
    
    let vc = UIHostingController(rootView: view)
    vc.view.frame = UIScreen.main.bounds
    
    let viewStore = ViewStore(
      store.scope(state: { _ in () }),
      removeDuplicates: ==
    )
    
    assertSnapshot(matching: vc, as: .image)
    
    viewStore.send(.themeChanged(.dark))
    assertSnapshot(matching: vc, as: .image)
    
    viewStore.send(.themeChanged(.light))
    assertSnapshot(matching: vc, as: .image)
  }
}

import SnapshotTesting
import SwiftUI
