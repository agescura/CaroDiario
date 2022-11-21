import SwiftUI
import ComposableArchitecture
import RootFeature
import Styles
import UserDefaultsClient
import CoreDataClientLive
import FileClient
import LocalAuthenticationClient
import UIApplicationClient
import AVCaptureDeviceClient
import FeedbackGeneratorClient
import AVAudioSessionClient
import AVAudioPlayerClient
import AVAudioRecorderClient
import StoreKitClient
import PDFKitClient
import AVAssetClient

class AppDelegate: NSObject, UIApplicationDelegate {
    let store: Store<RootState, RootAction>
    
    lazy var viewStore = ViewStore(
        store.scope(state: { _ in () }),
        removeDuplicates: ==
    )
    
    override init() {
        store = Store(
            initialState: .init(
                appDelegate: .init(),
                featureState: .splash(.init())
            ),
            reducer: rootReducer,
            environment: .init(
                coreDataClient: .live,
                fileClient: .live,
                userDefaultsClient: .live(userDefaults:)(),
                localAuthenticationClient: .live,
                applicationClient: .live,
                avCaptureDeviceClient: .live,
                feedbackGeneratorClient: .live,
                avAudioSessionClient: .live,
                avAudioPlayerClient: .live,
                avAudioRecorderClient: .live,
                storeKitClient: .live,
                pdfKitClient: .live,
                avAssetClient: .live,
                mainQueue: .main,
                backgroundQueue: DispatchQueue(label: "background-queue").eraseToAnyScheduler(),
                date: Date.init,
                uuid: UUID.init
            )
        )
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        registerFonts()
        return true
    }
    
    func process(url: URL) {
        viewStore.send(.process(url))
    }
    
    func update(state: ScenePhase) {
        viewStore.send(.state(state.value))
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(
            name: "Scene Configuration",
            sessionRole: connectingSceneSession.role
        )
        sceneConfiguration.delegateClass = SceneDelegate.self
        
        return sceneConfiguration
    }
}
