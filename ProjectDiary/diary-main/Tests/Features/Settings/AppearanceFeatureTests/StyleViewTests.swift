@testable import AppearanceFeature
import ComposableArchitecture
import EntriesFeature
import FeedbackGeneratorClient
import Models
import TestUtils
import XCTest

class StyleViewTests: XCTestCase {
	@MainActor
  func testStyleHappyPath() async {
    let store = TestStore(
			initialState: StyleFeature.State(entries: []),
			reducer: { StyleFeature() }
    )
    
    store.dependencies.feedbackGeneratorClient.selectionChanged = {}
    
    await store.send(.styleChanged(.rounded)) {
			$0.userSettings.appearance.styleType = .rounded
      $0.entries = fakeEntries
    }
    
    await store.send(.styleChanged(.rectangle)) {
			$0.userSettings.appearance.styleType = .rectangle
    }
  }
  
  func testSnapshot() {
    SnapshotTesting.diffTool = "ksdiff"
    
    assertSnapshot(
			StyleView(
				store: Store(
					initialState: StyleFeature.State(entries: fakeEntries),
					reducer: {  }
				)
			)
		)
		
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
		userSettings.appearance.styleType = .rounded
		
		assertSnapshot(
			StyleView(
				store: Store(
					initialState: StyleFeature.State(entries: fakeEntries),
					reducer: {  }
				)
			)
		)
  }
}

import SnapshotTesting
import SwiftUI
