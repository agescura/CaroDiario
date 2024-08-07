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
      initialState: .init(entryImage: entryImage),
      reducer: AttachmentImage()
    )
    
    store.send(.presentImageFullScreen(true))
  }
}
