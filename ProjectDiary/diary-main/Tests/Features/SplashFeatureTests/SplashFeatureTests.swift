import XCTest
@testable import SplashFeature
import ComposableArchitecture
import SwiftUI

@MainActor
class SplashFeatureTests: XCTestCase {
  func testSplashScreenHappyPath() async {
    let scheduler = DispatchQueue.test
    let store = TestStore(
      initialState: Splash.State(),
      reducer: Splash()
    )
    
    store.dependencies.mainQueue = scheduler.eraseToAnyScheduler()
    
    await store.send(.startAnimation)
    
    await scheduler.advance(by: .seconds(1))
    
    await store.receive(.verticalLineAnimation) {
      $0.animation = .verticalLine
    }
    
    await scheduler.advance(by: .seconds(1))
    
    await store.receive(.areaAnimation) {
      $0.animation = .horizontalArea
    }
    
    await scheduler.advance(by: .seconds(1))
    
    await store.receive(.finishAnimation) {
      $0.animation = .finish
    }
  }
}
