import ComposableArchitecture
import EntriesFeature
@testable import OnboardingFeature
import SwiftUI
import UserDefaultsClient
import XCTest

@MainActor
class PrivacyFeatureTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: PrivacyFeature.State(),
			reducer: PrivacyFeature()
		) {
			$0.userDefaultsClient.objectForKey = { _ in nil }
		}
		
		await store.send(.styleButtonTapped) {
			$0.style = StyleFeature.State(
				entries: fakeEntries,
				layoutType: .horizontal,
				styleType: .rectangle
			)
		}
	}
	
	func testSkip() async {
		let store = TestStore(
			initialState: PrivacyFeature.State(),
			reducer: PrivacyFeature()
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
