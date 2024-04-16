import XCTest
@testable import AgreementsFeature
import ComposableArchitecture
import SwiftUI

class AgreementsFeatureTests: XCTestCase {
	@MainActor
  func testOpenComposableArchitecture() async {
    let store = TestStore(
			initialState: AgreementsFeature.State(),
			reducer: { AgreementsFeature() }
    )
    store.dependencies.applicationClient.open = { url, _ in
      XCTAssertEqual(url.absoluteString, "https://github.com/pointfreeco/swift-composable-architecture")
    }
    
    await store.send(.open(.composableArchitecture))
  }
  
	@MainActor
  func testOpenRayWenderlich() async {
		let store = TestStore(
			initialState: AgreementsFeature.State(),
			reducer: { AgreementsFeature() }
		)
    store.dependencies.applicationClient.open = { url, _ in
      XCTAssertEqual(url.absoluteString, "https://www.raywenderlich.com/")
    }
    
    await store.send(.open(.raywenderlich))
  }
  
	@MainActor
  func testOpenPointfree() async {
		let store = TestStore(
			initialState: AgreementsFeature.State(),
			reducer: { AgreementsFeature() }
		)
    store.dependencies.applicationClient.open = { url, _ in
      XCTAssertEqual(url.absoluteString, "https://www.pointfree.co/")
    }
    
    await store.send(.open(.pointfree))
  }
  
  func testSnapshot() {
    SnapshotTesting.diffTool = "ksdiff"
    
		let view = AgreementsView(
      store: Store(
				initialState: AgreementsFeature.State(),
				reducer: { AgreementsFeature() }
      )
    )
    
    let vc = UIHostingController(rootView: view)
    vc.view.frame = UIScreen.main.bounds
    assertSnapshot(matching: vc, as: .image)
  }
}

import SnapshotTesting
