import ComposableArchitecture
import SnapshotTesting
import Testing
import SwiftUI

@testable import AboutFeature

@MainActor
@Suite(.snapshots(record: .failed, diffTool: .ksdiff))
struct AboutFeatureTests {
  @Test func testOpenConfirmationDialogAndOpenMail() async {
    let store = TestStore(
      initialState: AboutFeature.State(),
      reducer: { AboutFeature() }
    ) {
      $0.applicationClient.open = { url, _ in
        #expect(url.absoluteString == "mailto:carodiarioapp@gmail.com?subject=Bug%20in%20Caro%20Diario&body=%3CExplain%20your%20bug%20here%3E")
      }
    }
    
    await store.send(\.confirmationDialogButtonTapped) {
      $0.dialog = .dialog
    }
    
    await store.send(\.dialog.mail) {
      $0.dialog = nil
    }
  }
  
  @Test func testOpenConfirmationDialogAndGmailMail() async {
    let store = TestStore(
      initialState: AboutFeature.State(),
      reducer: { AboutFeature() }
    ) {
      $0.applicationClient.open = { url, _ in
        #expect(url.absoluteString == "googlegmail:///co?subject=Bug%20in%20Caro%20Diario&body=%3CExplain%20your%20bug%20here%3E&to=carodiarioapp@gmail.com")
      }
    }
    
    await store.send(\.confirmationDialogButtonTapped) {
      $0.dialog = .dialog
    }
    
    await store.send(\.dialog.gmail) {
      $0.dialog = nil
    }
  }
  
  @Test func testOpenConfirmationDialogAndOutlookMail() async {
    let store = TestStore(
      initialState: AboutFeature.State(),
      reducer: { AboutFeature() }
    ) {
      $0.applicationClient.open = { url, _ in
        #expect(url.absoluteString == "ms-outlook://compose?to=carodiarioapp@gmail.com&subject=Bug%20in%20Caro%20Diario&body=%3CExplain%20your%20bug%20here%3E")
      }
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
    
    await store.send(\.confirmationDialogButtonTapped) {
      $0.dialog = .dialog
    }
    
    await store.send(\.dialog.dismiss) {
      $0.dialog = nil
    }
  }
  
  @Test func testSnapshot() {
    assertSnapshot(
      NavigationStack {
        AboutView(
          store: Store(
            initialState: AboutFeature.State(),
            reducer: { AboutFeature() }
          )
        )
      }
    )
  }
}

public func assertSnapshot<Value: View>(
    _ value: @autoclosure () throws -> Value,
    named name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line
) {
    assertSnapshot(
        of: try value(),
        as: .image(perceptualPrecision: 0.98, layout: .device(config: .iPhone13Mini)),
        named: name,
        record: recording,
        timeout: timeout,
        fileID: fileID,
        file: file,
        testName: testName,
        line: line
    )
}
