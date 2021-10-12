//
//  SwitchClipView.swift
//  
//
//  Created by Albert Gil Escura on 8/10/21.
//

import ComposableArchitecture
import SwiftUI
import SplashFeature
import OnBoardingFeature
import UserDefaultsClient
import FeedbackGeneratorClient

public enum SwitchClipState: Equatable {
    case splash(SplashState)
    case onBoarding(WelcomeOnBoardingState)
}

public enum SwitchClipAction: Equatable {
    case splash(SplashAction)
    case onBoarding(WelcomeOnBoardingAction)
}

public struct SwitchClipEnvironment {
    public let userDefaultsClient: UserDefaultsClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let mainRunLoop: AnySchedulerOf<RunLoop>
    public let uuid: () -> UUID
    public let setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
    
    public init(
        userDefaultsClient: UserDefaultsClient,
        feedbackGeneratorClient: FeedbackGeneratorClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        mainRunLoop: AnySchedulerOf<RunLoop>,
        uuid: @escaping () -> UUID,
        setUserInterfaceStyle: @escaping (UIUserInterfaceStyle) -> Effect<Never, Never>
    ) {
        self.userDefaultsClient = userDefaultsClient
        self.feedbackGeneratorClient = feedbackGeneratorClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.mainRunLoop = mainRunLoop
        self.uuid = uuid
        self.setUserInterfaceStyle = setUserInterfaceStyle
    }
}

public let switchClipReducer: Reducer<SwitchClipState, SwitchClipAction, SwitchClipEnvironment> = .combine(

    splashReducer
        .pullback(
            state: /SwitchClipState.splash,
            action: /SwitchClipAction.splash,
            environment: { SplashEnvironment(
                userDefaultsClient: $0.userDefaultsClient,
                mainQueue: $0.mainQueue)
            }
        ),
    
    welcomeOnBoardingReducer
        .pullback(
            state: /SwitchClipState.onBoarding,
            action: /SwitchClipAction.onBoarding,
            environment: { WelcomeOnBoardingEnvironment(
                userDefaultsClient: $0.userDefaultsClient,
                feedbackGeneratorClient: $0.feedbackGeneratorClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                mainRunLoop: $0.mainRunLoop,
                uuid: $0.uuid,
                setUserInterfaceStyle: $0.setUserInterfaceStyle)
            }
        ),
    
        .init { state, action, environment in
            return .none
        }
)

public struct SwitchClipView: View {
    let store: Store<SwitchClipState, SwitchClipAction>
    
    public init(store: Store<SwitchClipState, SwitchClipAction>) {
        self.store = store
    }
    
    public var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /SwitchClipState.splash,
                action: SwitchClipAction.splash,
                then: SplashView.init(store:)
            )
            
            CaseLet(
                state: /SwitchClipState.onBoarding,
                action: SwitchClipAction.onBoarding,
                then: WelcomeOnBoardingView.init(store:)
            )
        }
    }
}
