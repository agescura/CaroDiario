import XCTest
@testable import AboutFeature
import ComposableArchitecture
import SwiftUI

class AboutFeatureTests: XCTestCase {
	@MainActor
  func testOpenConfirmationDialogAndOpenMail() async {
    let store = TestStore(
			initialState: AboutFeature.State(),
      reducer: { AboutFeature() }
    )
    store.dependencies.applicationClient.canOpen = { _ in true }
    store.dependencies.applicationClient.open = { url, _ in
      XCTAssertEqual(url.absoluteString, "mailto:carodiarioapp@gmail.com?subject=Bug%20in%20Caro%20Diario&body=%3CExplain%20your%20bug%20here%3E")
    }
    
    await store.send(\.confirmationDialogButtonTapped) {
			$0.dialog = .dialog
    }
    
		await store.send(\.dialog.mail) {
      $0.dialog = nil
    }
  }
  
	@MainActor
  func testOpenConfirmationDialogAndGmailMail() async {
		let store = TestStore(
			initialState: AboutFeature.State(),
			reducer: { AboutFeature() }
		)
    store.dependencies.applicationClient.canOpen = { _ in true }
    store.dependencies.applicationClient.open = { url, _ in
      XCTAssertEqual(url.absoluteString, "googlegmail:///co?subject=Bug%20in%20Caro%20Diario&body=%3CExplain%20your%20bug%20here%3E&to=carodiarioapp@gmail.com")
    }
    
		await store.send(\.confirmationDialogButtonTapped) {
			$0.dialog = .dialog
		}
    
		await store.send(\.dialog.gmail) {
      $0.dialog = nil
    }
  }
  
	@MainActor
  func testOpenConfirmationDialogAndOutlookMail() async {
		let store = TestStore(
			initialState: AboutFeature.State(),
			reducer: { AboutFeature() }
		)
    store.dependencies.applicationClient.canOpen = { _ in true }
    store.dependencies.applicationClient.open = { url, _ in
      XCTAssertEqual(url.absoluteString, "ms-outlook://compose?to=carodiarioapp@gmail.com&subject=Bug%20in%20Caro%20Diario&body=%3CExplain%20your%20bug%20here%3E")
    }
    
		await store.send(\.confirmationDialogButtonTapped) {
			$0.dialog = .dialog
		}
    
		await store.send(\.dialog.outlook) {
      $0.dialog = nil
    }
  }
  
	@MainActor
  func testOpenConfirmationDialogAndDimiss() async {
		let store = TestStore(
			initialState: AboutFeature.State(),
			reducer: { AboutFeature() }
		)
    store.dependencies.applicationClient.canOpen = { _ in true }
    
		await store.send(\.confirmationDialogButtonTapped) {
			$0.dialog = .dialog
		}
    
		await store.send(\.dialog.dismiss) {
      $0.dialog = nil
    }
  }
  
  func testSnapshot() {
		SnapshotTesting.diffTool = "ksdiff"
		
    let view = AboutView(
      store: Store(
				initialState: AboutFeature.State(),
        reducer: { AboutFeature() }
      )
    )
    
    let vc = UIHostingController(rootView: view)
    vc.view.frame = UIScreen.main.bounds
    assertSnapshot(matching: vc, as: .image)
  }
}

import SnapshotTesting


