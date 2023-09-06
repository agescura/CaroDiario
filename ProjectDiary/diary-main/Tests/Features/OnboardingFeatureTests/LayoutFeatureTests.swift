import ComposableArchitecture
import EntriesFeature
@testable import OnboardingFeature
import XCTest

@MainActor
class LayoutFeatureTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: LayoutFeature.State(
				entries: fakeEntries(
					with: .rectangle,
					layout: .horizontal
				),
				layoutType: .horizontal,
				styleType: .rectangle
			),
			reducer: LayoutFeature.init
		) {
			$0.userDefaultsClient.stringForKey = { _ in "" }
			$0.applicationClient.setUserInterfaceStyle = { _ in }
		}
		
		await store.send(.themeButtonTapped) {
			$0.destination = .theme(
				ThemeFeature.State(
					themeType: .system,
					entries: fakeEntries(
						with: .rectangle,
						layout: .horizontal
					)
				)
			)
		}
	}
	
	func testPresentAlertSkip() async {
		var setBoolCalled = (false, "")
		let store = TestStore(
			initialState: LayoutFeature.State(
				entries: fakeEntries(
					with: .rectangle,
					layout: .horizontal
				),
				layoutType: .horizontal,
				styleType: .rectangle
			),
			reducer: LayoutFeature.init
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
}
