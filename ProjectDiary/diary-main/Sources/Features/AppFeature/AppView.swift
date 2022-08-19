//
//  AppView.swift
//  
//
//  Created by Albert Gil Escura on 13/7/21.
//

import SwiftUI
import ComposableArchitecture
import SplashFeature
import OnBoardingFeature
import HomeFeature
import UserDefaultsClient
import CoreDataClient
import FileClient
import LockScreenFeature
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

public enum AppState: Equatable {
    case splash(SplashState)
    case onBoarding(WelcomeOnBoardingState)
    case lockScreen(LockScreenState)
    case home(HomeState)
}

public enum AppAction: Equatable {
    case splash(SplashAction)
    case onBoarding(WelcomeOnBoardingAction)
    case lockScreen(LockScreenAction)
    case home(HomeAction)
}

public struct AppEnvironment {
    public let fileClient: FileClient
    public let userDefaultsClient: UserDefaultsClient
    public let localAuthenticationClient: LocalAuthenticationClient
    public let applicationClient: UIApplicationClient
    public let avCaptureDeviceClient: AVCaptureDeviceClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let avAudioSessionClient: AVAudioSessionClient
    public let avAudioPlayerClient: AVAudioPlayerClient
    public let avAudioRecorderClient: AVAudioRecorderClient
    public let pdfKitClient: PDFKitClient
    public let avAssetClient: AVAssetClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let storeKitClient: StoreKitClient
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let date: () -> Date
    public let uuid: () -> UUID
    public let setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
    
    public init(
        fileClient: FileClient,
        userDefaultsClient: UserDefaultsClient,
        localAuthenticationClient: LocalAuthenticationClient,
        applicationClient: UIApplicationClient,
        avCaptureDeviceClient: AVCaptureDeviceClient,
        feedbackGeneratorClient: FeedbackGeneratorClient,
        avAudioSessionClient: AVAudioSessionClient,
        avAudioPlayerClient: AVAudioPlayerClient,
        avAudioRecorderClient: AVAudioRecorderClient,
        storeKitClient: StoreKitClient,
        pdfKitClient: PDFKitClient,
        avAssetClient: AVAssetClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        date: @escaping () -> Date,
        uuid: @escaping () -> UUID,
        setUserInterfaceStyle: @escaping (UIUserInterfaceStyle) -> Effect<Never, Never>
    ) {
        self.fileClient = fileClient
        self.userDefaultsClient = userDefaultsClient
        self.localAuthenticationClient = localAuthenticationClient
        self.applicationClient = applicationClient
        self.avCaptureDeviceClient = avCaptureDeviceClient
        self.feedbackGeneratorClient = feedbackGeneratorClient
        self.avAudioSessionClient = avAudioSessionClient
        self.avAudioPlayerClient = avAudioPlayerClient
        self.avAudioRecorderClient = avAudioRecorderClient
        self.storeKitClient = storeKitClient
        self.pdfKitClient = pdfKitClient
        self.avAssetClient = avAssetClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.date = date
        self.uuid = uuid
        self.setUserInterfaceStyle = setUserInterfaceStyle
    }
}

public let appReducer: Reducer<AppState, AppAction, AppEnvironment> = .combine(
    
    splashReducer
        .pullback(
            state: /AppState.splash,
            action: /AppAction.splash,
            environment: { SplashEnvironment(
                userDefaultsClient: $0.userDefaultsClient,
                mainQueue: $0.mainQueue)
            }
        ),
    
    welcomeOnBoardingReducer
        .pullback(
            state: /AppState.onBoarding,
            action: /AppAction.onBoarding,
            environment: { WelcomeOnBoardingEnvironment(
                userDefaultsClient: $0.userDefaultsClient,
                feedbackGeneratorClient: $0.feedbackGeneratorClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                date: $0.date,
                uuid: $0.uuid,
                setUserInterfaceStyle: $0.setUserInterfaceStyle)
            }
        ),
    
    lockScreenReducer
        .pullback(
            state: /AppState.lockScreen,
            action: /AppAction.lockScreen,
            environment: { LockScreenEnvironment(
                userDefaultsClient: $0.userDefaultsClient,
                localAuthenticationClient: $0.localAuthenticationClient,
                mainQueue: $0.mainQueue)
            }
        ),
    
    homeReducer
        .pullback(
            state: /AppState.home,
            action: /AppAction.home,
            environment: { HomeEnvironment(
                fileClient: $0.fileClient,
                userDefaultsClient: $0.userDefaultsClient,
                localAuthenticationClient: $0.localAuthenticationClient,
                applicationClient: $0.applicationClient,
                avCaptureDeviceClient: $0.avCaptureDeviceClient,
                feedbackGeneratorClient: $0.feedbackGeneratorClient,
                avAudioSessionClient: $0.avAudioSessionClient,
                avAudioPlayerClient: $0.avAudioPlayerClient,
                avAudioRecorderClient: $0.avAudioRecorderClient,
                storeKitClient: $0.storeKitClient,
                pdfKitClient: $0.pdfKitClient,
                avAssetClient: $0.avAssetClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                date: $0.date,
                uuid: $0.uuid,
                setUserInterfaceStyle: $0.setUserInterfaceStyle)
            }
        ),
    
    .init { state, action, environment in
        return .none
    }
)

public struct AppView: View {
    let store: Store<AppState, AppAction>
    
    public init(store: Store<AppState, AppAction>) {
        self.store = store
    }
    
    public var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /AppState.splash,
                action: AppAction.splash,
                then: SplashView.init(store:)
            )
            
            CaseLet(
                state: /AppState.onBoarding,
                action: AppAction.onBoarding,
                then: WelcomeOnBoardingView.init(store:)
            )
            
            CaseLet(
                state: /AppState.lockScreen,
                action: AppAction.lockScreen,
                then: LockScreenView.init(store:)
            )
            
            CaseLet(
                state: /AppState.home,
                action: AppAction.home,
                then: HomeView.init(store:)
            )
        }
    }
}
