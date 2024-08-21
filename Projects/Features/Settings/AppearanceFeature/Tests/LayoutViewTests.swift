@testable import AppearanceFeature
import ComposableArchitecture
import EntriesFeature
import Models
import SnapshotTesting
import TestUtils
import XCTest

@MainActor
class LayoutViewTests: XCTestCase {
	@MainActor
  func testAppearanceHappyPath() async {
    let store = TestStore(
			initialState: LayoutFeature.State(entries: []),
			reducer: { LayoutFeature() }
		)
    
    await store.send(.layoutChanged(.vertical)) {
			$0.userSettings.appearance.layoutType = .vertical
      $0.entries = fakeEntries
    }
  }
	
	func testSnapshot() {
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
			
			for language in Localizable.allCases {
				userSettings.language = language
				
				assertSnapshot(
					LayoutView(
						store: Store(
							initialState: LayoutFeature.State(entries: fakeEntries),
							reducer: { }
						)
					)
				)
				
				userSettings.appearance.layoutType = .vertical
				
				assertSnapshot(
					LayoutView(
						store: Store(
							initialState: LayoutFeature.State(entries: fakeEntries),
							reducer: { }
						)
					)
				)
				
				userSettings.appearance.layoutType = .horizontal
			}
		}
	}
}
