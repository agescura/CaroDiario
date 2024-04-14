//import XCTest
//import ComposableArchitecture
//@testable import AddEntryFeature
//import Models
//import ImagePickerFeature
//import AttachmentsFeature
//
//class AddEntryFeatureTests: XCTestCase {
//    
//    let id = UUID()
//    let imageId = UUID()
//    let videoId = UUID()
//    let date = Date()
//    let url = URL(string: "https://www.apple.com")!
//    
//    lazy var entryImage = EntryImage(
//        id: imageId,
//        lastUpdated: date,
//        thumbnail: url,
//        url: url
//    )
//    lazy var entryVideo = EntryVideo(
//        id: videoId,
//        lastUpdated: date,
//        thumbnail: url,
//        url: url
//    )
//    
//    lazy var entry = Entry(
//        id: id,
//        date: date,
//        startDay: date,
//        text: EntryText(
//            id: id,
//            message: "message",
//            lastUpdated: date
//        ),
//        attachments: [
//            entryImage,
//            entryVideo
//        ]
//    )
//    
//    func testAddEntryHappyPath() {
//        
//			let store = TestStore(
//				initialState: AddEntryFeature.State(entry: entry, type: .add),
//				reducer: { AddEntryFeature() }
//			)
//        
//        store.send(.onAppear) {
//            $0.text = "message"
//            $0.attachments = []
//        }
//        
//        store.send(.textEditorChange("new text")) {
//            $0.text = "new text"
//        }
//    }
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
