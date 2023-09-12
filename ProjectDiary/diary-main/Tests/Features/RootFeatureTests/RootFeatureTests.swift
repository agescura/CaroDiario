import ComposableArchitecture
import Models
import LockScreenFeature
import OnboardingFeature
import SplashFeature
@testable import RootFeature
import SwiftUI
import XCTest

@MainActor
class RootFeatureTests: XCTestCase {
    func test_openingFirstTime_NavigateToSplash() async {
		 let userSettings = UserSettings.defaultValue
		 
		 let store = TestStore(
			initialState: RootFeature.State(),
			reducer: RootFeature.init
		 ) {
			 $0.userDefaultsClient.userSettings = { userSettings }
			 $0.applicationClient.setUserInterfaceStyle = { _ in }
		 }
		 
		 await store.send(.didFinishLaunching)
		 await store.receive(.userSettingsResponse(.defaultValue))
		 
    }
    
    func test_openingDisabledSplashAndShownOnboarding_NavigateToHome() async {
		 var userSettings = UserSettings.defaultValue
		 userSettings.hasShownOnboarding = true
		 userSettings.showSplash = false
		 
		 let store = TestStore(
			initialState: RootFeature.State(),
			reducer: RootFeature.init
		 ) {
			 $0.userDefaultsClient.userSettings = { userSettings }
			 $0.applicationClient.setUserInterfaceStyle = { _ in }
		 }
		 
		 await store.send(.didFinishLaunching)
		 await store.receive(.userSettingsResponse(userSettings)) {
			 $0.userSettings = userSettings
			 $0.app = .splash(SplashFeature.State())
		 }
    }
    
	func test_openingDisabledSplashAndPasscode_NavigateToHome() async {
		let passcode = "1111"
		var userSettings = UserSettings.defaultValue
		userSettings.passcode = passcode
		userSettings.showSplash = false
		
		let store = TestStore(
		  initialState: RootFeature.State(),
		  reducer: RootFeature.init
		) {
			$0.userDefaultsClient.userSettings = { userSettings }
			$0.applicationClient.setUserInterfaceStyle = { _ in }
		}
		
		await store.send(.didFinishLaunching)
		await store.receive(.userSettingsResponse(userSettings)) {
			$0.userSettings = userSettings
			$0.app = .lockScreen(LockScreenFeature.State(code: passcode))
		}
    }
}
