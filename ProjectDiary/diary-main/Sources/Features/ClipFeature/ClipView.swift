//
//  ClipView.swift
//  
//
//  Created by Albert Gil Escura on 8/10/21.
//

import ComposableArchitecture
import SwiftUI
import UserDefaultsClient
import FeedbackGeneratorClient
import UIApplicationClient

public struct ClipState: Equatable {
    public var featureState: SwitchClipState
    
    public init(
        featureState: SwitchClipState
    ) {
        self.featureState = featureState
    }
}

public enum ClipAction: Equatable {
    case featureAction(SwitchClipAction)
    case onAppear
}

public struct ClipEnvironment {
    public let userDefaultsClient: UserDefaultsClient
    public let applicationClient: UIApplicationClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let mainRunLoop: AnySchedulerOf<RunLoop>
    public let uuid: () -> UUID
    public let setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
    
    public init(
        userDefaultsClient: UserDefaultsClient,
        applicationClient: UIApplicationClient,
        feedbackGeneratorClient: FeedbackGeneratorClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        mainRunLoop: AnySchedulerOf<RunLoop>,
        uuid: @escaping () -> UUID,
        setUserInterfaceStyle: @escaping (UIUserInterfaceStyle) -> Effect<Never, Never>
    ) {
        self.userDefaultsClient = userDefaultsClient
        self.applicationClient = applicationClient
        self.feedbackGeneratorClient = feedbackGeneratorClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.mainRunLoop = mainRunLoop
        self.uuid = uuid
        self.setUserInterfaceStyle = setUserInterfaceStyle
    }
}

public let clipReducer: Reducer<ClipState, ClipAction, ClipEnvironment> = .combine(
    
    switchClipReducer
        .pullback(
            state: \ClipState.featureState,
            action: /ClipAction.featureAction,
            environment: {
                SwitchClipEnvironment(
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
        switch action {
        case .onAppear:
            return Effect(value: ClipAction.featureAction(.splash(.startAnimation)))
            
        case .featureAction(.onBoarding(.privacyOnBoardingAction(.styleOnBoardingAction(.layoutOnBoardingAction(.themeOnBoardingAction(.startButtonTapped)))))):
            return .merge(
                environment.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
                    .fireAndForget(),
                environment.applicationClient.open(URL(string: "itms-apps://itunes.apple.com/app/apple-store/id375380948?mt=8")!, [:])
                    .fireAndForget()
            )
            
        case .featureAction(.splash(.finishAnimation)):
            state.featureState = .onBoarding(.init(isAppClip: true))
            return .none
            
        case .featureAction:
            return .none
        }
    }
)

public struct ClipView: View {
    let store: Store<ClipState, ClipAction>
    
    public init(
        store: Store<ClipState, ClipAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store.stateless) { viewStore in
            SwitchClipView(
                store: store.scope(
                    state: \.featureState,
                    action: ClipAction.featureAction
                )
            )
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
