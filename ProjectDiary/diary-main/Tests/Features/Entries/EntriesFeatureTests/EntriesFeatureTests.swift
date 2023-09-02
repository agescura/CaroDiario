import XCTest
@testable import EntriesFeature
import ComposableArchitecture
import SwiftUI
import Models
import AVAssetClient
import CoreDataClient

class EntriesFeatureTests: XCTestCase {
    let scheduler = DispatchQueue.test
    
    func testEntryWithImage() {
        let id = UUID()
        let date = Date()
        
        let store = TestStore(
            initialState: EntriesState(entries: []),
            reducer: entriesReducer,
            environment: .init(
                fileClient: .noop,
                userDefaultsClient: .noop,
                avCaptureDeviceClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                avAssetClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                date: Date.init,
                uuid: { id }
            )
        )
        
        store.send(.onAppear)
        
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
        }
    }
    
    func testEntryWithOnlyText() {
        let id = UUID()
        let date = Date()
        
        let store = TestStore(
            initialState: EntriesState(entries: []),
            reducer: entriesReducer,
            environment: EntriesEnvironment(
                fileClient: .noop,
                userDefaultsClient: .noop,
                avCaptureDeviceClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                avAssetClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                date: Date.init,
                uuid: { id }
            )
        )
        
        store.send(.onAppear)
        
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
        }
        store.receive(.addEntryAction(.createDraftEntry))
        
        store.send(.addEntryAction(.textEditorChange("Add Text Entry"))) {
            $0.addEntryState?.text = "Add Text Entry"
        }
        
        store.send(.addEntryAction(.addButtonTapped)) {
            $0.presentAddEntry = false
        }
    }
}
