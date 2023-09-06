import ComposableArchitecture
import EntriesFeature
@testable import OnboardingFeature
import XCTest

@MainActor
class StyleFeatureTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: StyleFeature.State(
				entries: fakeEntries(
					with: .rectangle,
					layout: .horizontal
				),
				layoutType: .horizontal,
				styleType: .rectangle
			),
			reducer: StyleFeature.init
		) {
			$0.userDefaultsClient.stringForKey = { _ in "" }
		}
		
		await store.send(.layoutButtonTapped) {
			$0.destination = .layout(
				LayoutFeature.State(
					entries: fakeEntries(
						with: .rectangle,
						layout: .horizontal
					),
					layoutType: .horizontal,
					styleType: .rectangle
				)
			)
		}
		
		func testPresentAlertSkip() async {
			var setBoolCalled = (false, "")
			let store = TestStore(
				initialState: StyleFeature.State(
					entries: fakeEntries(
						with: .rectangle,
						layout: .horizontal
					),
					layoutType: .horizontal,
					styleType: .rectangle
				),
				reducer: StyleFeature.init
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
}
