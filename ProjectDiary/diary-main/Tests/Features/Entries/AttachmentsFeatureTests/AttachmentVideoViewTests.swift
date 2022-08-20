//
//  AttachmentVideoViewTests.swift
//  
//
//  Created by Albert Gil Escura on 21/8/21.
//

import XCTest
import ComposableArchitecture
@testable import AttachmentsFeature
import Models

class AttachmentVideoViewTests: XCTestCase {
    
    func testAttachmentVideoRemoveFullScreen() {
        let id = UUID()
        let date = Date()
        let url = URL(string: "https://www.apple.com")!
        let entryVideo = EntryVideo(id: id, lastUpdated: date, thumbnail: url, url: url)
        
        let store = TestStore(
            initialState: AttachmentVideoState(entryVideo: entryVideo),
            reducer: attachmentVideoReducer,
            environment: ())
        
        store.send(.presentVideoPlayer(true)) { _ in
        }
    }
}
