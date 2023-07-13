import ComposableArchitecture
import Models
@testable import SearchFeature
import XCTest

class SearchFeatureTests: XCTestCase {
    func testHappyPath() {
		 let store = TestStore(
			initialState: SearchFeature.State(entries: [], searchText: ""),
			reducer: SearchFeature()
		 )
		 
        store.send(.searching(newText: "hello")) {
            $0.searchText = "hello"
        }
    }
    
}
