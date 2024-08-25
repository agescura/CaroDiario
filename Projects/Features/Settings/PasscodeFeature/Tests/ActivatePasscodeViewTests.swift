import ComposableArchitecture
import Models
@testable import PasscodeFeature
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

@MainActor
final class ActivatePasscodeViewTests: XCTestCase {
	@MainActor
	func testHappyPath() async {
		let store = TestStore(
			initialState: ActivateFeature.State(),
			reducer: { ActivateFeature() }
		)
		
		await store.send(\.view.insertButtonTapped)
		await store.receive(\.delegate.navigateToInsert)
	}
	
	func testSnapshot() {
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
			
			for language in Localizable.allCases {
				userSettings.language = language
				
				assertSnapshot(
					ActivateView(
						store: Store(
							initialState: ActivateFeature.State(),
							reducer: {}
						)
					)
				)
			}
		}
	}
}
