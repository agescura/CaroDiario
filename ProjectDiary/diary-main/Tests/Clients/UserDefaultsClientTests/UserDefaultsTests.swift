import Models
@testable import UserDefaultsClient
import XCTest

@MainActor
class UserDefaultsClientTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		
		UserDefaults.standard.removeObject(forKey: "hideSplashScreenKey")
		UserDefaults.standard.removeObject(forKey: "userSettingsKey")
		UserDefaults.standard.removeObject(forKey: "hasShownOnboardingKey")
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testFirstLaunch() async {
		let client = UserDefaultsClient.live(userDefaults: UserDefaults.standard)
		
		XCTAssertEqual(client.userSettings(), UserSettings.defaultValue)
	}
	
	func testSetUserSettings() async {
		let client = UserDefaultsClient.live(userDefaults: UserDefaults.standard)
		
		var userSettings: UserSettings = .defaultValue
		userSettings.hasShownOnboarding = true
		
		client.setUserSettings(userSettings)
		
		XCTAssertEqual(client.userSettings(), userSettings)
	}
	
	func testMigration() async {
		let client = UserDefaultsClient.live(userDefaults: UserDefaults.standard)
		
		client.setHideSplashScreen(true)
		client.setHasShownFirstLaunchOnboarding(true)
		client.set(styleType: .rounded)
		client.set(layoutType: .vertical)
		client.set(themeType: .dark)
		client.setLanguage("ca")
		
		var userSettings: UserSettings = .defaultValue
		userSettings.showSplash = true
		userSettings.hasShownOnboarding = true
		userSettings.appearance = AppearanceSettings(
			styleType: .rounded,
			layoutType: .vertical,
			themeType: .dark,
			iconAppType: .light
		)
		userSettings.language = .catalan
		
		XCTAssertEqual(client.userSettings(), userSettings)
	}
}
