//
//  AppDelegate.swift
//  ProjectDiary
//
//  Created by Albert Gil Escura on 1/8/21.
//

import SwiftUI
import ComposableArchitecture
import RootFeature
import SharedStyles
import UserDefaultsClientLive
import CoreDataClientLive
import FileClientLive
import LocalAuthenticationClientLive
import UIApplicationClientLive
import AVCaptureDeviceClientLive
import FeedbackGeneratorClientLive
import AVAudioSessionClientLive
import AVAudioPlayerClientLive
import AVAudioRecorderClientLive
import StoreKitClientLive
import PDFKitClientLive
import AVAssetClientLive

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
                mainRunLoop: .main,
                uuid: UUID.init,
                setUserInterfaceStyle: { userInterfaceStyle in
                    .fireAndForget {
                        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = userInterfaceStyle
                    }
                }
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
