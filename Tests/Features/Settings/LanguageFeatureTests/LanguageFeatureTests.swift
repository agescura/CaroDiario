import ComposableArchitecture
@testable import LanguageFeature
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
class LanguageFeatureTests: XCTestCase {
	
	func testHappyPath() async {
		let store = TestStore(
			initialState: LanguageFeature.State(
				language: .spanish
			),
			reducer: LanguageFeature()
		)
		
		await store.send(.updateLanguageTapped(.catalan)) {
			$0.language = .catalan
		}
	}
	
	func testSnapshot() async {
		let store = Store(
			initialState: LanguageFeature.State(
				language: .spanish
			),
			reducer: LanguageFeature()
		)
		let view = LanguageView(store: store)
		
		let vc = UIHostingController(rootView: view)
		vc.view.frame = UIScreen.main.bounds
		
		let viewStore = ViewStore(
			store,
			removeDuplicates: ==
		)
		
		assertSnapshot(matching: vc, as: .image)
		
		viewStore.send(.updateLanguageTapped(.catalan))
		assertSnapshot(matching: vc, as: .image)
	}
}
