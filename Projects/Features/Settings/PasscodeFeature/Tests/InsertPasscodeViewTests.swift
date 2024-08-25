import ComposableArchitecture
import Models
@testable import PasscodeFeature
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

@MainActor
final class InsertPasscodeViewTests: XCTestCase {
	@MainActor
	func testHappyPath() async {
		let store = TestStore(
			initialState: InsertFeature.State(),
			reducer: { InsertFeature() }
		)
		
		await store.send(.update(code: "1")) {
			$0.code = "1"
		}
		
		await store.send(.update(code: "1234")) {
			$0.code = ""
			$0.firstCode = "1234"
			$0.step = .secondCode
		}
		
		await store.send(.update(code: "1")) {
			$0.code = "1"
		}
		
		await store.send(.update(code: "1234")) {
			$0.code = "1234"
			$0.userSettings.passcode = "1234"
		}
		
		await store.receive(\.delegate.navigateToMenu)
	}
	
	func testSnapshot() {
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
			
			for language in Localizable.allCases {
				userSettings.language = language
				
				var state = InsertFeature.State()
				assertSnapshot(
					InsertView(
						store: Store(
							initialState: state,
							reducer: {}
						)
					)
				)
				
				state.code = "123"
				assertSnapshot(
					InsertView(
						store: Store(
							initialState: state,
							reducer: {}
						)
					)
				)
				
				state.codeNotMatched = true
				assertSnapshot(
					InsertView(
						store: Store(
							initialState: state,
							reducer: {}
						)
					)
				)
			}
		}
	}
}
