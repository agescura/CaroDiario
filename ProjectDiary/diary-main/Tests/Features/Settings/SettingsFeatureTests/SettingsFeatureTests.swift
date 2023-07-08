import AppearanceFeature
import ComposableArchitecture
import Models
@testable import SettingsFeature
import Styles
import SwiftUI
import UserDefaultsClient
import XCTest

@MainActor
class SettingsFeatureTests: XCTestCase {
	
	func testSettingsHappyPath() async {
		let store = TestStore(
			initialState: SettingsFeature.State(
				cameraStatus: .notDetermined,
				microphoneStatus: .notDetermined,
				userSettings: UserSettings(
					showSplash: true,
					hasShownOnboarding: true,
					appearance: AppearanceSettings(
						styleType: .rectangle,
						layoutType: .horizontal,
						themeType: .system,
						iconAppType: .light
					),
					language: .spanish,
					passcode: "",
					optionTimeForAskPasscode: 0,
					faceIdEnabled: false
				)
			),
			reducer: SettingsFeature()
		)
		
		await store.send(.toggleShowSplash(isOn: false)) {
			$0.showSplash = false
		}
		
		await store.send(.appearanceButtonTapped) {
			$0.destination = .appearance(
				AppearanceFeature.State(
					appearanceSettings: AppearanceSettings(
						styleType: .rectangle,
						layoutType: .horizontal,
						themeType: .system,
						iconAppType: .light
					)
				)
			)
		}
		
		await store.send(.destination(.dismiss)) {
			$0.destination = nil
		}
	}
}
