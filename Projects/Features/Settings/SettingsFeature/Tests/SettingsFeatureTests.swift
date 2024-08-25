import AppearanceFeature
import ComposableArchitecture
import Models
import PasscodeFeature
@testable import SettingsFeature
import SnapshotTesting
import Styles
import SwiftUI
import TestUtils
import UserDefaultsClient
import XCTest

@MainActor
class SettingsFeatureTests: XCTestCase {
	@MainActor
	func testShowHideSplash() async {
		let store = TestStore(
			initialState: SettingsFeature.State(),
			reducer: { SettingsFeature() }
		)
		
		await store.send(.toggleShowSplash(isOn: false)) {
			$0.userSettings.showSplash = false
		}
	}
	
	@MainActor
	func testNavigateToAppearance() async {
		let store = TestStore(
			initialState: SettingsFeature.State(),
			reducer: { SettingsFeature() }
		)
		await store.send(.path(.push(id: 0, state: .appearance(AppearanceFeature.State())))) {
			$0.path.append(.appearance(AppearanceFeature.State()))
		}
	}
	
	@MainActor
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
		await store.send(\.path[id: 0].activate.insertButtonTapped)
		await store.receive(\.path[id: 0].activate.delegate.navigateToInsert) {
			$0.path[id: 1] = .insert(InsertFeature.State())
		}
		await store.send(\.path[id: 1].insert.update, "1234") {
			$0.path[id: 1]?.insert?.code = ""
			$0.path[id: 1]?.insert?.firstCode = "1234"
			$0.path[id: 1]?.insert?.step = .secondCode
		}
		await store.send(\.path[id: 1].insert.update, "1234") {
			$0.path[id: 1]?.insert?.code = "1234"
			$0.userSettings.passcode = "1234"
		}
		await store.receive(\.path[id: 1].insert.delegate.navigateToMenu) {
			$0.path[id: 2] = .menu(MenuFeature.State())
		}
	}
	
	func testSnapshot() {
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
			
			for language in Localizable.allCases {
				userSettings.language = language
				
				assertSnapshot(
					SettingsView(
						store: Store(
							initialState: SettingsFeature.State(),
							reducer: {}
						)
					)
				)
				
				userSettings.showSplash = false
				
				assertSnapshot(
					SettingsView(
						store: Store(
							initialState: SettingsFeature.State(),
							reducer: {}
						)
					)
				)
				
				userSettings.showSplash = true
			}
		}
	}
}

