import XCTest
import ComposableArchitecture
@testable import AddEntryFeature
import Models
import ImagePickerFeature
import AttachmentsFeature

@MainActor
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
	
	func testAddEntryHappyPath() async {
		let store = TestStore(
			initialState: AddEntryFeature.State(
				entry: .new
			),
			reducer: AddEntryFeature()
		)
	}
}
