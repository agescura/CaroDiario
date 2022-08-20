//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import XCTest
@testable import AboutFeature
import ComposableArchitecture
import SwiftUI

class AgreementsFeatureTests: XCTestCase {
    func testOpenConfirmationDialogAndOpenMail() {
        var environment = AboutEnvironment(applicationClient: .noop)
        environment.applicationClient.open = { url, _ in
            XCTAssertEqual(url.absoluteString, "mailto:carodiarioapp@gmail.com?subject=Bug%20in%20Caro%20Diario&body=%3CExplain%20your%20bug%20here%3E")
            return .fireAndForget {}
        }
        let store = TestStore(
            initialState: AboutState(),
            reducer: aboutReducer,
            environment: environment
        )
        
        store.send(.emailOptionSheetButtonTapped) {
            $0.emailOptionSheet = .init(
                title: .init("Choose an option"),
                message: nil,
                buttons: [
                    .cancel(
                        .init("Cancel"),
                        action: .send(.dismissEmailOptionSheet)
                    ),
                    .default(
                        .init("Apple Mail"),
                        action: .send(.openMail)
                    ),
                    .default(
                        .init("Google Gmail"),
                        action: .send(.openGmail)
                    ),
                    .default(
                        .init("Microsoft Outlook"),
                        action: .send(.openOutlook)
                    )
                ]
            )
        }
        
        store.send(.openMail) {
            $0.emailOptionSheet = nil
        }
    }
    
    func testOpenConfirmationDialogAndGmailMail() {
        var environment = AboutEnvironment(applicationClient: .noop)
        environment.applicationClient.open = { url, _ in
            XCTAssertEqual(url.absoluteString, "googlegmail:///co?subject=Bug%20in%20Caro%20Diario&body=%3CExplain%20your%20bug%20here%3E&to=carodiarioapp@gmail.com")
            return .fireAndForget {}
        }
        let store = TestStore(
            initialState: AboutState(),
            reducer: aboutReducer,
            environment: environment
        )
        
        store.send(.emailOptionSheetButtonTapped) {
            $0.emailOptionSheet = .init(
                title: .init("Choose an option"),
                message: nil,
                buttons: [
                    .cancel(
                        .init("Cancel"),
                        action: .send(.dismissEmailOptionSheet)
                    ),
                    .default(
                        .init("Apple Mail"),
                        action: .send(.openMail)
                    ),
                    .default(
                        .init("Google Gmail"),
                        action: .send(.openGmail)
                    ),
                    .default(
                        .init("Microsoft Outlook"),
                        action: .send(.openOutlook)
                    )
                ]
            )
        }
        
        store.send(.openGmail) {
            $0.emailOptionSheet = nil
        }
    }
    
    func testOpenConfirmationDialogAndOutlookMail() {
        var environment = AboutEnvironment(applicationClient: .noop)
        environment.applicationClient.open = { url, _ in
            XCTAssertEqual(url.absoluteString, "ms-outlook://compose?to=carodiarioapp@gmail.com&subject=Bug%20in%20Caro%20Diario&body=%3CExplain%20your%20bug%20here%3E")
            return .fireAndForget {}
        }
        let store = TestStore(
            initialState: AboutState(),
            reducer: aboutReducer,
            environment: environment
        )
        
        store.send(.emailOptionSheetButtonTapped) {
            $0.emailOptionSheet = .init(
                title: .init("Choose an option"),
                message: nil,
                buttons: [
                    .cancel(
                        .init("Cancel"),
                        action: .send(.dismissEmailOptionSheet)
                    ),
                    .default(
                        .init("Apple Mail"),
                        action: .send(.openMail)
                    ),
                    .default(
                        .init("Google Gmail"),
                        action: .send(.openGmail)
                    ),
                    .default(
                        .init("Microsoft Outlook"),
                        action: .send(.openOutlook)
                    )
                ]
            )
        }
        
        store.send(.openOutlook) {
            $0.emailOptionSheet = nil
        }
    }
    
    func testOpenConfirmationDialogAndDimiss() {
        let store = TestStore(
            initialState: AboutState(),
            reducer: aboutReducer,
            environment: AboutEnvironment(applicationClient: .noop)
        )
        
        store.send(.emailOptionSheetButtonTapped) {
            $0.emailOptionSheet = .init(
                title: .init("Choose an option"),
                message: nil,
                buttons: [
                    .cancel(
                        .init("Cancel"),
                        action: .send(.dismissEmailOptionSheet)
                    ),
                    .default(
                        .init("Apple Mail"),
                        action: .send(.openMail)
                    ),
                    .default(
                        .init("Google Gmail"),
                        action: .send(.openGmail)
                    ),
                    .default(
                        .init("Microsoft Outlook"),
                        action: .send(.openOutlook)
                    )
                ]
            )
        }
        
        store.send(.dismissEmailOptionSheet) {
            $0.emailOptionSheet = nil
        }
    }
    
    func testSnapshot() {
        let view = AboutView(
            store: .init(
                initialState: .init(),
                reducer: aboutReducer,
                environment: .init(applicationClient: .noop)
            )
        )
        
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(matching: vc, as: .image)
    }
}

import SnapshotTesting


