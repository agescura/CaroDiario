import XCTest
@testable import OnboardingFeature
import ComposableArchitecture
import SwiftUI
import UserDefaultsClient

@MainActor
class WelcomeFeatureTests: XCTestCase {
	func testHappyPath() async {
		let mainQueue = DispatchQueue.test
		let store = TestStore(
			initialState: WelcomeFeature.State(),
			reducer: WelcomeFeature()
		) {
			$0.mainQueue = mainQueue.eraseToAnyScheduler()
		}
		
		await store.send(.selectedPage(0))
		await mainQueue.advance(by: .seconds(5))
		
		await store.receive(.nextPage) {
			$0.selectedPage = 1
			$0.tabViewAnimated = true
		}
		
		await store.send(.privacyButtonTapped) {
			$0.privacy = PrivacyFeature.State()
		}
	}
	
	func testSkip() async {
		let store = TestStore(
			initialState: WelcomeFeature.State(),
			reducer: WelcomeFeature()
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
