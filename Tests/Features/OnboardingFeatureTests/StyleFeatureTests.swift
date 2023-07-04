import ComposableArchitecture
import EntriesFeature
@testable import OnboardingFeature
import SwiftUI
import UserDefaultsClient
import XCTest

@MainActor
class StyleFeatureTests: XCTestCase {
	func testHappyPath() async {
		let store = TestStore(
			initialState: StyleFeature.State(
				entries: fakeEntries,
				layoutType: .horizontal,
				styleType: .rectangle
			),
			reducer: StyleFeature()
		) {
			$0.userDefaultsClient.objectForKey = { _ in nil }
			$0.feedbackGeneratorClient.selectionChanged = {}
		}
		
		await store.send(.styleChanged(.rounded)) {
			$0.styleType = .rounded
			$0.entries = EntriesFeature.fakeEntries(with: .rounded, layout: .horizontal)
		}
		
		await store.send(.layoutButtonTapped) {
			$0.layout = LayoutFeature.State(
				entries: EntriesFeature.fakeEntries(with: .rounded, layout: .horizontal),
				layoutType: .horizontal,
				styleType: .rounded
			)
		}
	}
	
	func testSkip() async {
		let store = TestStore(
			initialState: StyleFeature.State(
				entries: fakeEntries,
				layoutType: .horizontal,
				styleType: .rectangle
			),
			reducer: StyleFeature()
		)
		
		await store.send(.alertButtonTapped) {
			$0.alert = .alert
		}
		
		await store.send(.alert(.presented(.skipButtonTapped))) {
			$0.alert = nil
		}
		await store.receive(.delegate(.skip))
	}
}

private let id1 = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
private let id2 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
private let id3 = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
private let date = Date.init(timeIntervalSince1970: 1629486993)

var fakeEntries: IdentifiedArrayOf<DayEntriesRow.State> = [
	.init(dayEntry: .init(entry: [
		.init(id: id1, date: date, startDay: date, text: .init(id: id1, message: "Entries.FakeEntry.FirstMessage".localized, lastUpdated: date)),
		.init(id: id2, date: date, startDay: date, text: .init(id: id2, message: "Entries.FakeEntry.SecondMessage".localized, lastUpdated: date))
	], style: .rectangle, layout: .horizontal), id: id3)
]
