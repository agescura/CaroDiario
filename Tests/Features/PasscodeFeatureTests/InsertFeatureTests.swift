import ComposableArchitecture
import SwiftUI
import TestHelper
import Testing

@testable import PasscodeFeature

@MainActor
@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct InsertFeatureTests {
  @Test
  func testHappyPath() async {
    let store = TestStore(
      initialState: InsertFeature.State(),
      reducer: { InsertFeature() }
    )
    
    await store.send(\.update, "1") {
      $0.code = "1"
    }
    await store.send(\.update, "12") {
      $0.code = "12"
    }
    await store.send(\.update, "123") {
      $0.code = "123"
    }
    await store.send(\.update, "1234") {
      $0.code = ""
      $0.firstCode = "1234"
      $0.step = .secondCode
    }
    await store.send(\.update, "1") {
      $0.code = "1"
    }
    await store.send(\.update, "12") {
      $0.code = "12"
    }
    await store.send(\.update, "123") {
      $0.code = "123"
    }
    await store.send(\.update, "1234") {
      $0.code = "1234"
      $0.$userSettings.passcode.withLock { $0 = "1234" }
    }
    await store.receive(\.delegate.navigateToMenu)
  }
  
  @Test
  func testFail() async {
    let store = TestStore(
      initialState: InsertFeature.State(),
      reducer: { InsertFeature() }
    )
    
    await store.send(\.update, "1") {
      $0.code = "1"
    }
    await store.send(\.update, "12") {
      $0.code = "12"
    }
    await store.send(\.update, "123") {
      $0.code = "123"
    }
    await store.send(\.update, "1234") {
      $0.code = ""
      $0.firstCode = "1234"
      $0.step = .secondCode
    }
    await store.send(\.update, "1") {
      $0.code = "1"
    }
    await store.send(\.update, "11") {
      $0.code = "11"
    }
    await store.send(\.update, "111") {
      $0.code = "111"
    }
    await store.send(\.update, "1111") {
      $0.code = ""
      $0.codeNotMatched = true
      $0.firstCode = ""
      $0.step = .firstCode
    }
  }
  
  @Test func testPop() async {
    let store = TestStore(
      initialState: InsertFeature.State(),
      reducer: { InsertFeature() }
    )
    
    await store.send(\.view.popButtonTapped)
    await store.receive(\.delegate.popToRoot)
  }
}
