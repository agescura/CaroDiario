import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import Testing
import TestUtils

@testable import SplashFeature

@MainActor
struct SplashFeatureTests {
	@Test
	func testSplashScreenHappyPath() async {
		let store = TestStore(
			initialState: SplashFeature.State(),
			reducer: { SplashFeature() }
		)
		
		let clock = TestClock()
		store.dependencies.continuousClock = clock
		
		await store.send(.view(.task))
		
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
		await store.receive(\.delegate.animationFinished)
	}
	
	@Test
	func testSnapshot() {
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
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
}
