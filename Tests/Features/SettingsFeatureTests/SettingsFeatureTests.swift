import AppearanceFeature
import ComposableArchitecture
import Models
import PasscodeFeature
import SnapshotTesting
import SQLiteData
import SQLiteDataClient
import SwiftUI
import TestHelper
import Testing

@testable import SettingsFeature

@Suite(
  .dependencies {
    try! $0.bootstrapDatabase()
    try! $0.defaultDatabase.seed()
  }
)
@MainActor
struct SettingsFeatureTests {
  @Test
  func testShowHideSplash() async {
    let store = TestStore(
      initialState: SettingsFeature.State(),
      reducer: { SettingsFeature() }
    )
    
    await store.send(.toggleShowSplash(isOn: false)) {
      $0.$userSettings.showSplash.withLock { $0 = false }
    }
  }
  
  @Test
  func testNavigateToAppearance() async {
    let store = TestStore(
      initialState: SettingsFeature.State(),
      reducer: { SettingsFeature() }
    )
    await store.send(.path(.push(id: 0, state: .appearance(AppearanceFeature.State())))) {
      $0.path.append(.appearance(AppearanceFeature.State()))
    }
  }
  
  @Test
  func testInsertPasscode() async {
    let store = TestStore(
      initialState: SettingsFeature.State(),
      reducer: { SettingsFeature() }
    )
    
    await store.send(\.navigateToPasscode) {
      $0.path = StackState([
        .activate(ActivateFeature.State())
      ])
    }
    await store.send(\.path[id: 0].activate.view.insertButtonTapped)
    await store.receive(\.path[id: 0].activate.delegate.navigateToInsert) {
      $0.path[id: 1] = .insert(InsertFeature.State())
    }
    await store.send(\.path[id: 1].insert.update, "1234") {
      $0.path[id: 1]?.modify(\.insert) { $0.code = "" }
      $0.path[id: 1]?.modify(\.insert) { $0.firstCode = "1234" }
      $0.path[id: 1]?.modify(\.insert) { $0.step = .secondCode }
    }
    await store.send(\.path[id: 1].insert.update, "1234") {
      $0.path[id: 1]?.modify(\.insert) { $0.code = "1234" }
      $0.$userSettings.passcode.withLock { $0 = "1234" }
    }
    await store.receive(\.path[id: 1].insert.delegate.navigateToMenu) {
      $0.path[id: 2] = .menu(MenuFeature.State())
    }
  }
  
  //  @Test
  //	func testSnapshot() {
  //		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
  //			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
  //
  //			for language in Localizable.allCases {
  //        $userSettings.language.withLock { $0 = language }
  //
  //				assertSnapshot(
  //					SettingsView(
  //						store: Store(
  //							initialState: SettingsFeature.State(),
  //							reducer: {}
  //						)
  //					)
  //				)
  //
  //        $userSettings.showSplash.withLock { $0 = false }
  //
  //				assertSnapshot(
  //					SettingsView(
  //						store: Store(
  //							initialState: SettingsFeature.State(),
  //							reducer: {}
  //						)
  //					)
  //				)
  //
  //        $userSettings.showSplash.withLock { $0 = true }
  //			}
  //		}
  //	}
}
