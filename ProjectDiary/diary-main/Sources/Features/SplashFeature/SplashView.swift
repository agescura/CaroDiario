//
//  OnboardingView.swift
//  OnboardingFeature
//
//  Created by Albert Gil Escura on 26/6/21.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import SharedStyles

public struct SplashState: Equatable {
    public var animation: AnimationState
    
    public init(
        animation: AnimationState = .start
    ) {
        self.animation = animation
    }
    
    public enum AnimationState: Equatable {
        case start
        case verticalLine
        case horizontalArea
        case finish
    }
}

extension SplashState.AnimationState {
    var lineHeight: CGFloat {
        switch self {
        case .start:
            return 0
        case .verticalLine, .horizontalArea, .finish:
            return .infinity
        }
    }
    
    var lineWidth: CGFloat {
        switch self {
        case .start, .verticalLine:
            return 1
        case .horizontalArea, .finish:
            return .infinity
        }
    }
    
    var duration: Animation? {
        switch self {
        case .start, .verticalLine, .horizontalArea:
            return .easeOut(duration: 0.5)
        case .finish:
            return nil
        }
    }
}

public enum SplashAction: Equatable {
    case startAnimation
    case verticalLineAnimation
    case areaAnimation
    case finishAnimation
}

public struct SplashEnvironment {
    var userDefaultsClient: UserDefaultsClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init(
        userDefaultsClient: UserDefaultsClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.userDefaultsClient = userDefaultsClient
        self.mainQueue = mainQueue
    }
}

public let splashReducer = Reducer<SplashState, SplashAction, SplashEnvironment> { state, action, environment in
    
    switch action {
    
    case .startAnimation:
        return Effect(value: SplashAction.verticalLineAnimation)
            .delay(for: 1, scheduler: environment.mainQueue)
            .eraseToEffect()
        
    case .verticalLineAnimation:
        state.animation = .verticalLine
        return Effect(value: SplashAction.areaAnimation)
            .delay(for: 1, scheduler: environment.mainQueue)
            .eraseToEffect()
        
    case .areaAnimation:
        state.animation = .horizontalArea
        return Effect(value: SplashAction.finishAnimation)
            .delay(for: 1, scheduler: environment.mainQueue)
            .eraseToEffect()
        
    case .finishAnimation:
        state.animation = .finish
        return .none
    }
}

public struct SplashView: View {
    let store: Store<SplashState, SplashAction>
    
    public init(
        store: Store<SplashState, SplashAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.chambray
                
                HStack {
                    Divider()
                        .frame(
                            minWidth: 1,
                            maxWidth: viewStore.animation.lineWidth,
                            minHeight: 0,
                            maxHeight: viewStore.animation.lineHeight
                        )
                        .background(Color.adaptiveWhite)
                        .animation(viewStore.animation.duration, value: 0.5)
                }
            }
            .ignoresSafeArea()
        }
    }
}
