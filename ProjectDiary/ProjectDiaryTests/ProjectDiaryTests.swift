import XCTest
import SnapshotTesting
import ComposableArchitecture
import RootFeature
import SwiftUI

class ProjectDiaryTests: XCTestCase {

//    func testExample() {
//        let store = Store(
//            initialState: RootState(appDelegate: .init(), featureState: .onBoarding(.init())),
//            reducer: rootReducer,
//            environment: RootEnvironment(
//                coreDataClient: .noop,
//                fileClient: .noop,
//                userDefaultsClient: .noop,
//                localAuthenticationClient: .noop,
//                applicationClient: .noop,
//                avCaptureDeviceClient: .noop,
//                feedbackGeneratorClient: .noop,
//                avAudioSessionClient: .noop,
//                avAudioPlayerClient: .noop,
//                avAudioRecorderClient: .noop,
//                mainQueue: .immediate,
//                backgroundQueue: .immediate,
//                mainRunLoop: .immediate,
//                uuid: UUID.init
//                )
//        )
//        let view = RootView(store: store)
//        let vc = UIHostingController(rootView: view)
//        vc.view.frame = UIScreen.main.bounds
//        
//        let viewStore = ViewStore(
//            store.scope(state: { _ in () }),
//            removeDuplicates: ==
//        )
//        
//        
//        viewStore.send(.appDelegate(.didFinishLaunching))
//        
//        assertSnapshot(matching: vc, as: .image)
//    }
}
