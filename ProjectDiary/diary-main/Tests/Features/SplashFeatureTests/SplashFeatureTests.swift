import ComposableArchitecture
@testable import SplashFeature
import SwiftUI
import XCTest

@MainActor
class SplashFeatureTests: XCTestCase {
	func testHappyPath() async {
		let mainQueue = DispatchQueue.test
		
		let store = TestStore(
			initialState: SplashFeature.State(),
			reducer: SplashFeature.init
		) {
			$0.mainQueue = mainQueue.eraseToAnyScheduler()
		}
		
		await store.send(.startAnimation)
		
		await mainQueue.advance(by: .seconds(1))
		
		await store.receive(.animation(.start))
		
		await mainQueue.advance(by: .seconds(1))
		
		await store.receive(.animation(.verticalLine)) {
			$0.animation = .verticalLine
		}
		
		await mainQueue.advance(by: .seconds(1))
		
		await store.receive(.animation(.area)) {
			$0.animation = .horizontalArea
		}
		
		await store.receive(.animation(.finish)) {
			$0.animation = .finish
		}
		
		await store.receive(.delegate(.finishAnimation))
	}
}
