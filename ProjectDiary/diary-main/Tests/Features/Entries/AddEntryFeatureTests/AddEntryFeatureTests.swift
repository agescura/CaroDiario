//
//  AddEntryFeatureTests.swift
//  AddEntryFeatureTests
//
//  Created by Albert Gil Escura on 25/6/21.
//

import XCTest
import ComposableArchitecture
@testable import AddEntryFeature
import Models
import ImagePickerFeature
import AttachmentsFeature

class AddEntryFeatureTests: XCTestCase {
    
    let id = UUID()
    let imageId = UUID()
    let videoId = UUID()
    let date = Date()
    let url = URL(string: "https://www.apple.com")!
    
    lazy var entryImage = EntryImage(
        id: imageId,
        lastUpdated: date,
        thumbnail: url,
        url: url
    )
    lazy var entryVideo = EntryVideo(
        id: videoId,
        lastUpdated: date,
        thumbnail: url,
        url: url
    )
    
    lazy var entry = Entry(
        id: id,
        date: date,
        startDay: date,
        text: EntryText(
            id: id,
            message: "message",
            lastUpdated: date
        ),
        attachments: [
            entryImage,
            entryVideo
        ]
    )
    
    func testAddEntryHappyPath() {
        
        let store = TestStore(
            initialState: AddEntryState(type: .add, entry: entry),
            reducer: addEntryReducer,
            environment: AddEntryEnvironment(
                coreDataClient: .noop,
                fileClient: .noop,
                avCaptureDeviceClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                avAssetClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate,
                mainRunLoop: .immediate,
                uuid: UUID.init
            )
        )
        
        store.send(.onAppear) {
            $0.text = "message"
            $0.attachments = [
                AttachmentAddRowState(id: self.imageId, attachment: .image(.init(entryImage: self.entryImage))),
                AttachmentAddRowState(id: self.videoId, attachment: .video(.init(entryVideo: self.entryVideo)))
            ]
        }
        
        store.send(.textEditorChange("new text")) {
            $0.text = "new text"
        }
    }
}





































