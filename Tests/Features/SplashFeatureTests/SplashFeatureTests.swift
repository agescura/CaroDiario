import XCTest
@testable import SplashFeature
import ComposableArchitecture
import SwiftUI

@MainActor
class SplashFeatureTests: XCTestCase {
	func testHappyPath() async {
		let mainQueue = DispatchQueue.test
		let store = TestStore(
			initialState: SplashFeature.State(),
			reducer: SplashFeature()
		) {
			$0.mainQueue = mainQueue.eraseToAnyScheduler()
		}
		
		await store.send(.start)
		await store.receive(.verticalLine) {
			$0.animation = .verticalLine
		}
		await mainQueue.advance(by: .seconds(1))
		await store.receive(.area) {
			$0.animation = .horizontalArea
		}
		await mainQueue.advance(by: .seconds(1))
		await store.receive(.finish) {
			$0.animation = .finish
		}
		await store.receive(.delegate(.finished))
	}
}
