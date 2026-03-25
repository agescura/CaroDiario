import ComposableArchitecture
import SwiftUI
import TestHelper
import Testing

@testable import PasscodeFeature

@MainActor
@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct MenuFeatureTests {
  @Test
  func testHappyPath() async {
    let store = TestStore(
      initialState: MenuFeature.State(),
      reducer: { MenuFeature() }
    )
  }
}
