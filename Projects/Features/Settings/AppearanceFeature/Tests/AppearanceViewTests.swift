@testable import AppearanceFeature
import ComposableArchitecture
import EntriesFeature
import Models
import SnapshotTesting
import TestUtils
import XCTest

@MainActor
class AppearanceViewTests: XCTestCase {
	@MainActor
	func testHappyPath() async {
		let store = TestStore(
			initialState: AppearanceFeature.State(),
			reducer: { AppearanceFeature() }
		)
		
		await store.send(.iconAppButtonTapped)
		await store.receive(.delegate(.navigateToIconApp))
		
		await store.send(.layoutButtonTapped)
		await store.receive(.delegate(.navigateToLayout))
		
		await store.send(.styleButtonTapped)
		await store.receive(.delegate(.navigateToStyle))
		
		await store.send(.themeButtonTapped)
		await store.receive(.delegate(.navigateToTheme))
	}
	
	func testSnapshot() {
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
			
			for language in Localizable.allCases {
				userSettings.language = language
				
				assertSnapshot(
					AppearanceView(
						store: Store(
							initialState: AppearanceFeature.State(),
							reducer: {}
						)
					)
				)
			}
		}
	}
}
