@testable import AppearanceFeature
import EntriesFeature
import ComposableArchitecture
import Models
import TestUtils
import XCTest

@MainActor
class ThemeViewTests: XCTestCase {
	@MainActor
  func testHappyPath() async {
    let store = TestStore(
			initialState: ThemeFeature.State(entries: []),
			reducer: { ThemeFeature() }
		) {
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
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
			
			for language in Localizable.allCases {
				userSettings.language = language
				
				assertSnapshot(
					ThemeView(
						store: Store(
							initialState: ThemeFeature.State(entries: fakeEntries),
							reducer: {  }
						)
					)
				)
				
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
				
				userSettings.appearance.themeType = .system
			}
		}
  }
}

import SnapshotTesting
import SwiftUI
