import ComposableArchitecture
@testable import LockScreenFeature
import Models
import SwiftUI
import XCTest

class LockScreenFeatureTests: XCTestCase {
	@MainActor
	func testLockScreenHappyPath() async {
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
		userSettings.passcode = "1111"
		
		let store = TestStore(
			initialState: LockScreenFeature.State(),
			reducer: { LockScreenFeature() }
		)
		
		await store.send(\.numberButtonTapped, .number(1)) {
			$0.codeToMatch = "1"
		}
		await store.send(\.numberButtonTapped ,.number(1)) {
			$0.codeToMatch = "11"
		}
		await store.send(\.numberButtonTapped, .number(1)) {
			$0.codeToMatch = "111"
		}
		await store.send(\.numberButtonTapped, .number(1)) {
			$0.codeToMatch = "1111"
		}
		await store.receive(\.delegate.matchedCode)
	}
	
	@MainActor
	func testLockScreenFailed() async {
		let clock = TestClock()
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
		userSettings.passcode = "1111"
		
		let store = TestStore(
			initialState: LockScreenFeature.State(),
			reducer: { LockScreenFeature() }
		) {
			$0.continuousClock = clock
		}
		
		await store.send(\.numberButtonTapped, .number(1)) {
			$0.codeToMatch = "1"
		}
		await store.send(\.numberButtonTapped, .number(2)) {
			$0.codeToMatch = "12"
		}
		await store.send(\.numberButtonTapped, .number(3)) {
			$0.codeToMatch = "123"
		}
		await store.send(\.numberButtonTapped, .number(4)) {
			$0.codeToMatch = "1234"
		}
		await clock.advance(by: .seconds(0.5))
		await store.receive(\.failedCode) {
			$0.codeToMatch = ""
			$0.wrongAttempts = 4
		}
		await store.receive(\.reset) {
			$0.wrongAttempts = 0
		}
	}
}
