//
//  AttachmentImageViewTests.swift
//  
//
//  Created by Albert Gil Escura on 21/8/21.
//

import XCTest
import ComposableArchitecture
@testable import AttachmentsFeature
import SharedModels

class AttachmentImageViewTests: XCTestCase {
    
    func testAttachmentImageRemoveFullScreen() {
        let id = UUID()
        let date = Date()
        let url = URL(string: "https://www.apple.com")!
        let entryImage = EntryImage(id: id, lastUpdated: date, thumbnail: url, url: url)
        
        let store = TestStore(
            initialState: AttachmentImageState(entryImage: entryImage),
            reducer: attachmentImageReducer,
            environment: AttachmentImageEnvironment(
                fileClient: .noop,
                applicationClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate)
        )
        
        store.send(.presentImageFullScreen(true)) {
            $0.presentImageFullScreen = true
        }
        
        store.send(.removeFullScreenAlertButtonTapped) {
            $0.removeFullScreenAlert = .init(
                title: .init("Are you sure that you want to remove the image?"),
                primaryButton: .cancel(.init("Cancel")),
                secondaryButton: .destructive(.init("Remove"), action: .send(.remove))
            )
        }
        
        store.send(.remove) {
            $0.removeFullScreenAlert = nil
            $0.presentImageFullScreen = false
        }
    }
    
    func testAttachmentImageRemove() {
        let id = UUID()
        let date = Date()
        let url = URL(string: "https://www.apple.com")!
        let entryImage = EntryImage(id: id, lastUpdated: date, thumbnail: url, url: url)
        
        let store = TestStore(
            initialState: AttachmentImageState(entryImage: entryImage),
            reducer: attachmentImageReducer,
            environment: AttachmentImageEnvironment(
                fileClient: .noop,
                applicationClient: .noop,
                mainQueue: .immediate,
                backgroundQueue: .immediate)
        )
        
        store.send(.presentImageFullScreen(true)) {
            $0.presentImageFullScreen = true
        }
        
        store.send(.dismissRemoveFullScreen) {
            $0.presentImageFullScreen = false
        }
        
        store.send(.remove)
    }
}
