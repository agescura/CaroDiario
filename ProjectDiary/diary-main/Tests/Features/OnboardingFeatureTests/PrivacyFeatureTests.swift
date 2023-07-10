import ComposableArchitecture
import EntriesFeature
@testable import OnboardingFeature
import XCTest

@MainActor
class PrivacyFeatureTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: PrivacyFeature.State(),
			reducer: PrivacyFeature()
		) {
			$0.userDefaultsClient.stringForKey = { _ in "" }
		}
		
		await store.send(.styleButtonTapped) {
			$0.destination = .style(
				StyleFeature.State(
					styleType: .rectangle,
					layoutType: .horizontal,
					entries: fakeEntries(
						with: .rectangle,
						layout: .horizontal
					)
				)
			)
		}
	}
	
	func testPresentAlertSkip() async {
		let store = TestStore(
			initialState: PrivacyFeature.State(),
			reducer: PrivacyFeature()
		)
		
		await store.send(.alertButtonTapped) {
			$0.destination = .alert(.skip)
		}
		
		await store.send(.destination(.presented(.alert(.skipButtonTapped)))) {
			$0.destination = nil
		}
		
		await store.receive(.delegate(.skip))
	}
}
