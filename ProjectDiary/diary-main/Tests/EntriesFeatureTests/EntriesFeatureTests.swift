//
//  EntriesFeatureTests.swift
//  
//
//  Created by Albert Gil Escura on 11/7/21.
//

import XCTest
@testable import EntriesFeature
import ComposableArchitecture
import SwiftUI
import SharedModels

class EntriesFeatureTests: XCTestCase {
    let scheduler = DispatchQueue.test
    
    func testEntryWithImage() {
        let runLoop = RunLoop.test
        let id = UUID()
        let date = Date()
        
        var coreDataClientCreateCalled = false
        var coreDataClientDestroyCalled = false
        var coreDataClientCreateDraftCalled = false
        var coreDataClientPublishEntryCalled = false
        var coreDataClientUpdateMessageCalled = false
        
        let store = TestStore(
            initialState: EntriesState(entries: []),
            reducer: entriesReducer,
            environment: .init(
                coreDataClient: .init(
                    create: { _ in
                        coreDataClientCreateCalled = true
                        return .fireAndForget {}
                    },
                    destroy: { _ in
                        coreDataClientDestroyCalled = true
                        return .fireAndForget {}
                    },
                    createDraft: { _ in
                        coreDataClientCreateDraftCalled = true
                        return .fireAndForget {}
                    },
                    publishEntry: { _ in
                        coreDataClientPublishEntryCalled = true
                        return .fireAndForget {}
                    },
                    removeEntry: { _ in .fireAndForget {} },
                    fetchEntry: { _ in .fireAndForget {} },
                    fetchAll: { .fireAndForget {} },
                    updateMessage: { _, _ in
                        coreDataClientUpdateMessageCalled = true
                        return .fireAndForget {}
                    },
                    addAttachmentEntry: { _, _ in .fireAndForget {} },
                    removeAttachmentEntry: { _ in .fireAndForget {} },
                    searchEntries: { _ in .fireAndForget {} },
                    searchImageEntries: { .fireAndForget {} },
                    searchVideoEntries: { .fireAndForget {} },
                    searchAudioEntries: { .fireAndForget {} }
                ),
                fileClient: .noop,
                userDefaultsClient: .noop,
                avCaptureDeviceClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                mainRunLoop: runLoop.eraseToAnyScheduler(),
                uuid: { id }
            )
        )
        
        store.send(.onAppear) { _ in
            XCTAssertTrue(coreDataClientCreateCalled)
        }
        
        store.send(.presentAddEntry(true)) {
            $0.presentAddEntry = true
            $0.addEntryState = .init(
                type: .add,
                entry: .init(
                    id: id,
                    date: date,
                    startDay: date,
                    text: .init(
                        id: id,
                        message: "",
                        lastUpdated: date
                    )
                )
            )
            XCTAssertTrue(coreDataClientCreateDraftCalled)
        }
        store.receive(.addEntryAction(.createDraftEntry))
        
        store.send(.addEntryAction(.textEditorChange("Add Text Entry"))) {
            $0.addEntryState?.text = "Add Text Entry"
        }
        
        store.send(.addEntryAction(.presentImagePicker(true))) {
            $0.addEntryState?.presentImagePicker = true
            $0.addEntryState?.addAttachmentInFlight = true
        }
        
        store.send(.addEntryAction(.addButtonTapped)) {
            $0.presentAddEntry = false
            XCTAssertTrue(coreDataClientUpdateMessageCalled)
            XCTAssertTrue(coreDataClientPublishEntryCalled)
        }
        
        store.send(.onDissapear) { _ in
            XCTAssertTrue(coreDataClientDestroyCalled)
        }
    }
    
    func testEntryWithOnlyText() {
        let runLoop = RunLoop.test
        let id = UUID()
        let date = Date()
        
        var coreDataClientCreateCalled = false
        var coreDataClientDestroyCalled = false
        var coreDataClientCreateDraftCalled = false
        var coreDataClientPublishEntryCalled = false
        var coreDataClientUpdateMessageCalled = false
        
        let store = TestStore(
            initialState: EntriesState(entries: []),
            reducer: entriesReducer,
            environment: EntriesEnvironment(
                coreDataClient: .init(
                    create: { _ in
                        coreDataClientCreateCalled = true
                        return .fireAndForget {}
                    },
                    destroy: { _ in
                        coreDataClientDestroyCalled = true
                        return .fireAndForget {}
                    },
                    createDraft: { _ in
                        coreDataClientCreateDraftCalled = true
                        return .fireAndForget {}
                    },
                    publishEntry: { _ in
                        coreDataClientPublishEntryCalled = true
                        return .fireAndForget {}
                    },
                    removeEntry: { _ in .fireAndForget {} },
                    fetchEntry: { _ in .fireAndForget {} },
                    fetchAll: { .fireAndForget {} },
                    updateMessage: { _, _ in
                        coreDataClientUpdateMessageCalled = true
                        return .fireAndForget {}
                    },
                    addAttachmentEntry: { _, _ in .fireAndForget {} },
                    removeAttachmentEntry: { _ in .fireAndForget {} },
                    searchEntries: { _ in .fireAndForget {} },
                    searchImageEntries: { .fireAndForget {} },
                    searchVideoEntries: { .fireAndForget {} },
                    searchAudioEntries: { .fireAndForget {} }),
                fileClient: .noop,
                userDefaultsClient: .noop,
                avCaptureDeviceClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                mainRunLoop: runLoop.eraseToAnyScheduler(),
                uuid: { id }
            )
        )
        
        store.send(.onAppear) { _ in
            XCTAssertTrue(coreDataClientCreateCalled)
        }
        
        store.send(.presentAddEntry(true)) {
            $0.presentAddEntry = true
            $0.addEntryState = .init(
                type: .add,
                entry: .init(
                    id: id,
                    date: date,
                    startDay: date,
                    text: .init(
                        id: id,
                        message: "",
                        lastUpdated: date
                    )
                )
            )
            XCTAssertTrue(coreDataClientCreateDraftCalled)
        }
        store.receive(.addEntryAction(.createDraftEntry))
        
        store.send(.addEntryAction(.textEditorChange("Add Text Entry"))) {
            $0.addEntryState?.text = "Add Text Entry"
        }
        
        store.send(.addEntryAction(.addButtonTapped)) {
            $0.presentAddEntry = false
            XCTAssertTrue(coreDataClientUpdateMessageCalled)
            XCTAssertTrue(coreDataClientPublishEntryCalled)
        }
        
        store.send(.onDissapear) { _ in
            XCTAssertTrue(coreDataClientDestroyCalled)
        }
    }
}
