@testable import AboutFeature
import ComposableArchitecture
import SwiftUI
import XCTest

@MainActor
class AboutFeatureTests: XCTestCase {
	func testOpenMail() async {
		let store = TestStore(
			initialState: .init(),
			reducer: AboutFeature()
		)
		store.dependencies.applicationClient.canOpen = { _ in true }
		store.dependencies.applicationClient.open = { url, _ in
			XCTAssertEqual(url.absoluteString, "mailto:carodiarioapp@gmail.com?subject=Bug%20in%20Caro%20Diario&body=%3CExplain%20your%20bug%20here%3E")
		}
		
		await store.send(.confirmationDialogButtonTapped) {
			$0.dialog = .dialog
		}
		
		await store.send(.dialog(.presented(.mail))) {
			$0.dialog = nil
		}
	}
	
	func testOpenGmail() async {
		let store = TestStore(
			initialState: .init(),
			reducer: AboutFeature()
		)
		store.dependencies.applicationClient.canOpen = { _ in true }
		store.dependencies.applicationClient.open = { url, _ in
			XCTAssertEqual(url.absoluteString, "googlegmail:///co?subject=Bug%20in%20Caro%20Diario&body=%3CExplain%20your%20bug%20here%3E&to=carodiarioapp@gmail.com")
		}
		
		await store.send(.confirmationDialogButtonTapped) {
			$0.dialog = .dialog
		}
		
		await store.send(.dialog(.presented(.gmail))) {
			$0.dialog = nil
		}
	}
	
	func testOpenOutlook() async {
		let store = TestStore(
			initialState: .init(),
			reducer: AboutFeature()
		)
		store.dependencies.applicationClient.canOpen = { _ in true }
		store.dependencies.applicationClient.open = { url, _ in
			XCTAssertEqual(url.absoluteString, "ms-outlook://compose?to=carodiarioapp@gmail.com&subject=Bug%20in%20Caro%20Diario&body=%3CExplain%20your%20bug%20here%3E")
		}
		
		await store.send(.confirmationDialogButtonTapped) {
			$0.dialog = .dialog
		}
		
		await store.send(.dialog(.presented(.outlook))) {
			$0.dialog = nil
		}
	}
	
	func testDismiss() async {
		let store = TestStore(
			initialState: .init(),
			reducer: AboutFeature()
		)
		
		await store.send(.confirmationDialogButtonTapped) {
			$0.dialog = .dialog
		}
		
		await store.send(.dialog(.dismiss)) {
			$0.dialog = nil
		}
	}

	func testSnapshot() {
		SnapshotTesting.diffTool = "ksdiff"

		let store = Store(
			initialState: AboutFeature.State(),
			reducer: AboutFeature()
		)
		let view = AboutView(store: store)
		
		lazy var viewStore = ViewStore(
			store,
			removeDuplicates: ==
		)

		let vc = UIHostingController(rootView: view)
		vc.view.frame = UIScreen.main.bounds
		assertSnapshot(matching: vc, as: .image)
		
		viewStore.send(.confirmationDialogButtonTapped)
		assertSnapshot(matching: vc, as: .image)
	}
}

import SnapshotTesting


