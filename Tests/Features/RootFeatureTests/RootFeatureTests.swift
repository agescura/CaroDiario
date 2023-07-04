import AppFeature
import ComposableArchitecture
import EntriesFeature
import Models
@testable import RootFeature
import SplashFeature
import SwiftUI
import UserDefaultsClient
import XCTest

@MainActor
class RootFeatureTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: RootFeature.State(
				appDelegate: AppDelegateState(),
				feature: .splash(
					SplashFeature.State()
				)
			),
			reducer: RootFeature()
		) {
			$0.userDefaultsClient.objectForKey = { _ in nil }
		}
		
		await store.send(.appDelegate(.didFinishLaunching))
		
		await store.send(.splashFinished)
	}
	
	func testHideSplashScreen() async {
		let store = TestStore(
			initialState: RootFeature.State(
				appDelegate: AppDelegateState(),
				feature: .splash(
					SplashFeature.State()
				)
			),
			reducer: RootFeature()
		) {
			$0.userDefaultsClient.objectForKey = { _ in
				var userSettings: UserSettings = .defaultValue
				userSettings.showSplash = true
				let encoder = JSONEncoder()
				if let encoded = try? encoder.encode(userSettings) {
					return encoded
				}
				return nil
			}
		}
		
		await store.send(.appDelegate(.didFinishLaunching))
	}
}

