import XCTest
@testable import AgreementsFeature
import ComposableArchitecture
import SwiftUI

@MainActor
class AgreementsFeatureTests: XCTestCase {
  func testOpenComposableArchitecture() async {
    let store = TestStore(
      initialState: .init(),
      reducer: Agreements()
    )
    store.dependencies.applicationClient.open = { url, _ in
      XCTAssertEqual(url.absoluteString, "https://github.com/pointfreeco/swift-composable-architecture")
    }
    
    await store.send(.open(.composableArchitecture))
  }
  
  func testOpenRayWenderlich() async {
    let store = TestStore(
      initialState: .init(),
      reducer: Agreements()
    )
    store.dependencies.applicationClient.open = { url, _ in
      XCTAssertEqual(url.absoluteString, "https://www.raywenderlich.com/")
    }
    
    await store.send(.open(.raywenderlich))
  }
  
  func testOpenPointfree() async {
    let store = TestStore(
      initialState: .init(),
      reducer: Agreements()
    )
    store.dependencies.applicationClient.open = { url, _ in
      XCTAssertEqual(url.absoluteString, "https://www.pointfree.co/")
    }
    
    await store.send(.open(.pointfree))
  }
  
  func testSnapshot() {
    SnapshotTesting.diffTool = "ksdiff"
    
    let view = AgreementsView(
      store: .init(
        initialState: .init(),
        reducer: Agreements()
      )
    )
    
    let vc = UIHostingController(rootView: view)
    vc.view.frame = UIScreen.main.bounds
    assertSnapshot(matching: vc, as: .image)
  }
}

import SnapshotTesting
