//
//  AttachmentVideoViewTests.swift
//  
//
//  Created by Albert Gil Escura on 21/8/21.
//

import XCTest
import ComposableArchitecture
@testable import AttachmentsFeature
import SharedModels

class AttachmentVideoViewTests: XCTestCase {
    
    func testAttachmentVideoRemoveFullScreen() {
        let id = UUID()
        let date = Date()
        let url = URL(string: "https://www.apple.com")!
        let entryVideo = EntryVideo(id: id, lastUpdated: date, thumbnail: url, url: url)
        
        let store = TestStore(
            initialState: AttachmentVideoState(entryVideo: entryVideo),
            reducer: attachmentVideoReducer,
            environment: AttachmentVideoEnvironment(
                fileClient: .noop,
                applicationClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate)
        )
        
        store.send(.presentVideoPlayer(true)) {
            $0.presentVideoPlayer = true
        }
        
        store.send(.videoAlertButtonTapped) {
            $0.videoAlert = .init(
                title: .init("Are you sure that you want to remove the video?"),
                primaryButton: .cancel(.init("Cancel")),
                secondaryButton: .destructive(.init("Remove"), action: .send(.remove)))
        }
        
        store.send(.remove) {
            $0.presentVideoPlayer = false
            $0.videoAlert = nil
        }
    }
    
    func testAttachmentVideoRemove() {
        let id = UUID()
        let date = Date()
        let url = URL(string: "https://www.apple.com")!
        let entryVideo = EntryVideo(id: id, lastUpdated: date, thumbnail: url, url: url)
        
        let store = TestStore(
            initialState: AttachmentVideoState(entryVideo: entryVideo),
            reducer: attachmentVideoReducer,
            environment: AttachmentVideoEnvironment(
                fileClient: .noop,
                applicationClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate)
        )
        
        store.send(.presentVideoPlayer(true)) {
            $0.presentVideoPlayer = true
        }
        
        store.send(.dismissRemoveFullScreen) {
            $0.presentVideoPlayer = false
        }
        
        store.send(.remove)
    }
}
