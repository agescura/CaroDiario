import ComposableArchitecture
@testable import OnboardingFeature
import SwiftUI
import XCTest

@MainActor
class WelcomeFeatureTests: XCTestCase {
	func testHappyPath() async {
		let mainQueue = DispatchQueue.test
		
		let store = TestStore(
			initialState: WelcomeFeature.State(),
			reducer: WelcomeFeature.init
		) {
			$0.mainQueue = mainQueue.eraseToAnyScheduler()
		}
		
		await store.send(.selectedPage(0))
		
		await mainQueue.advance(by: .seconds(5))
		
		await store.receive(.nextPage) {
			$0.tabViewAnimated = true
			$0.selectedPage = 1
		}
		
		await mainQueue.advance(by: .seconds(5))
		
		await store.receive(.nextPage) {
			$0.selectedPage = 2
		}
		
		await mainQueue.advance(by: .seconds(5))
		
		await store.receive(.nextPage) {
			$0.selectedPage = 0
		}
		
		await store.send(.privacyButtonTapped) {
			$0.destination = .privacy(
				PrivacyFeature.State()
			)
		}
	}
	
	func testPresentAlertSkipCancellingEffects() async {
		var setBoolCalled = (false, "")
		let store = TestStore(
			initialState: WelcomeFeature.State(),
			reducer: WelcomeFeature.init
		) {
			$0.userDefaultsClient.setBool = { setBoolCalled = ($0, $1) }
		}
		
		await store.send(.alertButtonTapped) {
			$0.destination = .alert(.skip)
		}
		
		await store.send(.destination(.presented(.alert(.skipButtonTapped)))) {
			$0.destination = nil
		}
		
		XCTAssertEqual(setBoolCalled.0, true)
		XCTAssertEqual(setBoolCalled.1, "hasShownOnboardingKey")
		
		await store.receive(.delegate(.skip))
	}
	
	func testSnapshot() async {
		SnapshotTesting.diffTool = "ksdiff"
		let mainQueue = DispatchQueue.test
		
		let store = Store(
			initialState: WelcomeFeature.State(),
			reducer: WelcomeFeature.init
		) {
			$0.mainQueue = mainQueue.eraseToAnyScheduler()
		}
		let view = WelcomeView(store: store)
		
		let vc = UIHostingController(rootView: view)
		vc.view.frame = UIScreen.main.bounds
		assertSnapshot(matching: vc, as: .image)
		
		store.send(.selectedPage(0))
		
		await mainQueue.advance(by: .seconds(5))
		assertSnapshot(matching: vc, as: .image)
		
		await mainQueue.advance(by: .seconds(5))
		assertSnapshot(matching: vc, as: .image)
		
		await mainQueue.advance(by: .seconds(5))
		assertSnapshot(matching: vc, as: .image)
	}
}

import SnapshotTesting
