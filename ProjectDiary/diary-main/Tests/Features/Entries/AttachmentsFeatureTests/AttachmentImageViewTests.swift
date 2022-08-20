//
//  AttachmentImageViewTests.swift
//  
//
//  Created by Albert Gil Escura on 21/8/21.
//

import XCTest
import ComposableArchitecture
@testable import AttachmentsFeature
import Models

class AttachmentImageViewTests: XCTestCase {
    
    func testAttachmentImageRemoveFullScreen() {
        let id = UUID()
        let date = Date()
        let url = URL(string: "https://www.apple.com")!
        let entryImage = EntryImage(id: id, lastUpdated: date, thumbnail: url, url: url)
        
        let store = TestStore(
            initialState: AttachmentImageState(entryImage: entryImage),
            reducer: attachmentImageReducer,
            environment: ())
        
        store.send(.presentImageFullScreen(true)) { _ in
        }
    }
}
