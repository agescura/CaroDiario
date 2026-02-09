@testable import AppFeature
import ComposableArchitecture
import EntriesFeature
import HomeFeature
import LockScreenFeature
import Models
import OnboardingFeature
import SwiftUI
import Testing

struct AppFeatureTests {
	@MainActor
	func testHappyPath() async {
		let clock = TestClock()
		let store = TestStore(
			initialState: AppFeature.State(),
			reducer: { AppFeature() }
		) {
			$0.applicationClient.setUserInterfaceStyle = { _ in }
      $0.avCaptureDeviceClient.authorizationStatus = { .notDetermined }
			$0.continuousClock = clock
		}
		
		await store.send(\.appDelegate.didFinishLaunching)
    await store.receive(\.authorizationStatusResponse, .notDetermined)
		await store.send(\.scene.splash.view.task)
		await clock.advance(by: .seconds(1))
		await store.receive(\.scene.splash.verticalLineAnimation) {
      $0.scene.modify(\.splash) { $0.animation = .verticalLine }
		}
		await clock.advance(by: .seconds(1))
		await store.receive(\.scene.splash.areaAnimation) {
      $0.scene.modify(\.splash) { $0.animation = .horizontalArea }
		}
		await clock.advance(by: .seconds(1))
		await store.receive(\.scene.splash.finishAnimation) {
      $0.scene.modify(\.splash) { $0.animation = .finish }
		}
		await store.receive(\.scene.splash.delegate.animationFinished)
		await store.receive(\.splashFinished) {
			$0.scene = .onboarding(WelcomeFeature.State())
		}
		await store.send(\.scene.onboarding.delegate.navigateToHome) {
			$0.scene = .home(HomeFeature.State())
		}
	}
	
	@MainActor
	func testHideSplash() async {
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
    $userSettings.showSplash.withLock { $0 = false }
		
		let store = TestStore(
			initialState: AppFeature.State(),
			reducer: { AppFeature() }
		) {
			$0.applicationClient.setUserInterfaceStyle = { _ in }
		}
		
		await store.send(.appDelegate(.didFinishLaunching))
		await store.receive(\.splashFinished) {
			$0.scene = .onboarding(WelcomeFeature.State())
		}
	}
	
	@MainActor
	func testLockScreen() async {
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
    $userSettings.showSplash.withLock { $0 = false }
    $userSettings.passcode.withLock { $0 = "1234" }
		
		let store = TestStore(
			initialState: AppFeature.State(),
			reducer: { AppFeature() }
		) {
			$0.applicationClient.setUserInterfaceStyle = { _ in }
		}
		
		await store.send(.appDelegate(.didFinishLaunching))
		await store.receive(\.splashFinished) {
			$0.scene = .lockScreen(LockScreenFeature.State())
		}
		await store.send(\.scene.lockScreen.numberButtonTapped, .number(1)) {
      $0.scene.modify(\.lockScreen) { $0.codeToMatch = "1" }
		}
		await store.send(\.scene.lockScreen.numberButtonTapped, .number(2)) {
      $0.scene.modify(\.lockScreen) { $0.codeToMatch = "12" }
		}
		await store.send(\.scene.lockScreen.numberButtonTapped, .number(3)) {
      $0.scene.modify(\.lockScreen) { $0.codeToMatch = "123" }
		}
		await store.send(\.scene.lockScreen.numberButtonTapped, .number(4)) {
      $0.scene.modify(\.lockScreen) { $0.codeToMatch = "1234" }
		}
		await store.receive(\.scene.lockScreen.delegate.matchedCode) {
			$0.scene = .home(HomeFeature.State())
		}
	}
}
