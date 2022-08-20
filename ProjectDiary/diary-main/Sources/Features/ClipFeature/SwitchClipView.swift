//
//  SwitchClipView.swift
//  
//
//  Created by Albert Gil Escura on 8/10/21.
//

import ComposableArchitecture
import SwiftUI
import SplashFeature
import OnboardingFeature
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
    public let date: () -> Date
    public let uuid: () -> UUID
    public let setUserInterfaceStyle: (UIUserInterfaceStyle) async -> Void
    
    public init(
        userDefaultsClient: UserDefaultsClient,
        feedbackGeneratorClient: FeedbackGeneratorClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        date: @escaping () -> Date,
        uuid: @escaping () -> UUID,
        setUserInterfaceStyle: @escaping (UIUserInterfaceStyle) async -> Void
    ) {
        self.userDefaultsClient = userDefaultsClient
        self.feedbackGeneratorClient = feedbackGeneratorClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.date = date
        self.uuid = uuid
        self.setUserInterfaceStyle = setUserInterfaceStyle
    }
}

public let switchClipReducer: Reducer<
    SwitchClipState,
    SwitchClipAction,
    SwitchClipEnvironment
> = .combine(
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
                date: $0.date,
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
    
    public init(
        store: Store<SwitchClipState, SwitchClipAction>
    ) {
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
