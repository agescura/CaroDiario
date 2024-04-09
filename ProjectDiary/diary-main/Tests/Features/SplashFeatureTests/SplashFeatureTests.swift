import ComposableArchitecture
@testable import SplashFeature
import TestUtils
import SwiftUI
import XCTest

@MainActor
class SplashFeatureTests: XCTestCase {
	func testSplashScreenHappyPath() async {
		let store = TestStore(
			initialState: SplashFeature.State(),
			reducer: { SplashFeature() }
		)
		
		let clock = TestClock()
		store.dependencies.continuousClock = clock
		
		await store.send(.startAnimation)
		
		await clock.advance(by: .seconds(1))
		
		await store.receive(.verticalLineAnimation) {
			$0.animation = .verticalLine
		}
		
		await clock.advance(by: .seconds(1))
		
		await store.receive(.areaAnimation) {
			$0.animation = .horizontalArea
		}
		
		await clock.advance(by: .seconds(1))
		
		await store.receive(.finishAnimation) {
			$0.animation = .finish
		}
	}
	
	func testSnapshot() async {
		assertSnapshot(
			SplashView(
				store: Store(
					initialState: SplashFeature.State(),
					reducer: { }
				)
			)
		)
		
		assertSnapshot(
			SplashView(
				store: Store(
					initialState: SplashFeature.State(animation: .verticalLine),
					reducer: { }
				)
			)
		)
		
		assertSnapshot(
			SplashView(
				store: Store(
					initialState: SplashFeature.State(animation: .horizontalArea),
					reducer: { }
				)
			)
		)
		
		assertSnapshot(
			SplashView(
				store: Store(
					initialState: SplashFeature.State(animation: .finish),
					reducer: { }
				)
			)
		)
	}
}
