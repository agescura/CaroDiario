@testable import AppearanceFeature
import ComposableArchitecture
import EntriesFeature
import Models
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

@MainActor
class StyleViewTests: XCTestCase {
	@MainActor
  func testStyleHappyPath() async {
    let store = TestStore(
			initialState: StyleFeature.State(entries: []),
			reducer: { StyleFeature() }
    )

    await store.send(.styleChanged(.rounded)) {
			$0.userSettings.appearance.styleType = .rounded
      $0.entries = fakeEntries
    }
    
    await store.send(.styleChanged(.rectangle)) {
			$0.userSettings.appearance.styleType = .rectangle
    }
  }
  
  func testSnapshot() {
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
			
			for language in Localizable.allCases {
				userSettings.language = language
				
				assertSnapshot(
					StyleView(
						store: Store(
							initialState: StyleFeature.State(entries: fakeEntries),
							reducer: {  }
						)
					)
				)
				
				userSettings.appearance.styleType = .rounded
				
				assertSnapshot(
					StyleView(
						store: Store(
							initialState: StyleFeature.State(entries: fakeEntries),
							reducer: {  }
						)
					)
				)
				
				userSettings.appearance.styleType = .rectangle
			}
		}
  }
}
