import AppearanceFeature
import ComposableArchitecture
import Styles
@testable import SettingsFeature
import SwiftUI
import UserDefaultsClient
import XCTest

@MainActor
class SettingsFeatureTests: XCTestCase {
	
	func testSettingsHappyPath() async {
		let store = TestStore(
			initialState: SettingsFeature.State(
				userSettings: .defaultValue
			),
			reducer: SettingsFeature()
		) {
			$0.userDefaultsClient.objectForKey = { _ in nil }
			$0.userDefaultsClient.setObject = { _,_ in }
			$0.avCaptureDeviceClient.authorizationStatus = { .authorized }
			$0.localAuthenticationClient.determineType = { .none }
		}
		
		await store.send(.appearanceButtonTapped) {
			$0.destination = .appearance(
				AppearanceFeature.State(appearanceSettings: .defaultValue)
			)
		}
		
		await store.send(.destination(.dismiss)) {
			$0.destination = nil
		}
	}
}
