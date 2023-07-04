import ComposableArchitecture
import EntriesFeature
@testable import OnboardingFeature
import SwiftUI
import UserDefaultsClient
import XCTest

@MainActor
class LayoutFeatureTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: LayoutFeature.State(
				entries: fakeEntries,
				layoutType: .horizontal,
				styleType: .rectangle
			),
			reducer: LayoutFeature()
		) {
			$0.userDefaultsClient.objectForKey = { _ in nil }
			$0.applicationClient.setUserInterfaceStyle = { _ in }
		}
		
		await store.send(.themeButtonTapped) {
			$0.theme = ThemeFeature.State(
				entries: fakeEntries,
				themeType: .system
			)
		}
	}
	
	func testSkip() async {
		let store = TestStore(
			initialState: LayoutFeature.State(
				entries: fakeEntries,
				layoutType: .horizontal,
				styleType: .rectangle
			),
			reducer: LayoutFeature()
		)
		
		await store.send(.alertButtonTapped) {
			$0.alert = .alert
		}
		
		await store.send(.alert(.presented(.skipButtonTapped))) {
			$0.alert = nil
		}
		await store.receive(.delegate(.skip))
	}
}
