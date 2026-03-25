import ComposableArchitecture
import SwiftUI
import Testing

@testable import PasscodeFeature

@MainActor
@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct ActivateFeatureTests {
  @Test
  func testHappyPath() async {
    let store = TestStore(
      initialState: ActivateFeature.State(),
      reducer: { ActivateFeature() }
    )
    
    await store.send(\.view.insertButtonTapped)
    await store.receive(\.delegate.navigateToInsert)
  }
}
