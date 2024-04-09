@testable import AppearanceFeature
import EntriesFeature
import ComposableArchitecture
import Models
import TestUtils
import XCTest

@MainActor
class ThemeViewTests: XCTestCase {
  
  func testThemeHappyPath() async {
    var selectionChangedCalled = false
		let store = TestStore(
			initialState: ThemeFeature.State(entries: []),
			reducer: { ThemeFeature() }
		) {
			$0.feedbackGeneratorClient.selectionChanged = {}
			$0.applicationClient.setUserInterfaceStyle = { _ in }
		}

    await store.send(.themeChanged(.dark)) {
			$0.userSettings.appearance.themeType = .dark
    }
    
    await store.send(.themeChanged(.light)) {
			$0.userSettings.appearance.themeType = .light
    }
  }
  
  func testSnapshot() {
    SnapshotTesting.diffTool = "ksdiff"
    
    assertSnapshot(
			ThemeView(
				store: Store(
					initialState: ThemeFeature.State(entries: fakeEntries),
					reducer: {  }
				)
			)
		)
		
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
		userSettings.appearance.themeType = .light
		
		assertSnapshot(
			ThemeView(
				store: Store(
					initialState: ThemeFeature.State(entries: fakeEntries),
					reducer: {  }
				)
			)
		)
		
		userSettings.appearance.themeType = .dark
		
		assertSnapshot(
			ThemeView(
				store: Store(
					initialState: ThemeFeature.State(entries: fakeEntries),
					reducer: {  }
				)
			)
		)
  }
}

import SnapshotTesting
import SwiftUI
