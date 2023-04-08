import XCTest
@testable import SplashFeature
import ComposableArchitecture
import SwiftUI

@MainActor
class SplashFeatureTests: XCTestCase {
  func testSplashScreenHappyPath() async {
    let store = TestStore(
      initialState: SplashFeature.State(),
      reducer: SplashFeature()
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
}
