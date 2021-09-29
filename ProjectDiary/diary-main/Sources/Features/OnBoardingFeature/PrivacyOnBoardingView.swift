//
//  PrivacyOnBoardingView.swift
//  
//
//  Created by Albert Gil Escura on 18/7/21.
//

import SwiftUI
import ComposableArchitecture
import SharedViews
import UserDefaultsClient
import SharedStyles
import FeedbackGeneratorClient
import EntriesFeature

public struct PrivacyOnBoardingState: Equatable {
    public var styleOnBoardingState: StyleOnBoardingState? = nil
    public var navigateStyleOnBoarding: Bool = false
    
    public var skipAlert: AlertState<PrivacyOnBoardingAction>?
    
    public init(
        styleOnBoardingState: StyleOnBoardingState? = nil,
        navigateStyleOnBoarding: Bool = false
    ) {
        self.styleOnBoardingState = styleOnBoardingState
        self.navigateStyleOnBoarding = navigateStyleOnBoarding
    }
}

public enum PrivacyOnBoardingAction: Equatable {
    case styleOnBoardingAction(StyleOnBoardingAction)
    case navigationStyleOnBoarding(Bool)
    
    case skipAlertButtonTapped
    case cancelSkipAlert
    case skipAlertAction
}

public struct PrivacyOnBoardingEnvironment {
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

let privacyOnBoardingReducer: Reducer<PrivacyOnBoardingState, PrivacyOnBoardingAction, PrivacyOnBoardingEnvironment> = .combine(
    
    styleOnBoardingReducer
        .optional()
        .pullback(
            state: \PrivacyOnBoardingState.styleOnBoardingState,
            action: /PrivacyOnBoardingAction.styleOnBoardingAction,
            environment: { StyleOnBoardingEnvironment(
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
        
        case .styleOnBoardingAction:
            return .none
            
        case let .navigationStyleOnBoarding(value):
            let styleType = environment.userDefaultsClient.styleType
            let layoutType = environment.userDefaultsClient.layoutType
            
            state.navigateStyleOnBoarding = value
            state.styleOnBoardingState = value ? .init(
                styleType: styleType,
                layoutType: layoutType,
                entries: fakeEntries(with: styleType,
                                     layout: layoutType)) : nil
            return .none
            
        case .skipAlertButtonTapped:
            state.skipAlert = .init(
                title: .init("OnBoarding.Skip.Title".localized),
                message: .init("OnBoarding.Skip.Alert".localized),
                primaryButton: .cancel(.init("Cancel".localized), action: .send(.cancelSkipAlert)),
                secondaryButton: .destructive(.init("OnBoarding.Skip".localized), action: .send(.skipAlertAction))
            )
            return .none
            
        case .cancelSkipAlert:
            state.skipAlert = nil
            return .none
            
        case .skipAlertAction:
            state.skipAlert = nil
            return environment.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
                .fireAndForget()
        }
    }
)

public struct PrivacyOnBoardingView: View {
    let store: Store<PrivacyOnBoardingState, PrivacyOnBoardingAction>
    
    public init(
        store: Store<PrivacyOnBoardingState, PrivacyOnBoardingAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                Text("OnBoarding.Important".localized)
                    .adaptiveFont(.latoRegular, size: 24)
                    .foregroundColor(.adaptiveBlack)
                
                HStack(alignment: .center) {
                    Image(systemName: "hand.raised")
                        .resizable()
                        .foregroundColor(.adaptiveGray)
                        .scaledToFill()
                        .frame(width: 18, height: 18)
                        .offset(y: 8)
                    
                    Text("OnBoarding.Privacy".localized)
                        .adaptiveFont(.latoItalic, size: 12)
                        .foregroundColor(.adaptiveGray)
                }

                Spacer()
                
                NavigationLink(
                    "",
                    destination:
                        IfLetStore(
                            store.scope(
                                state: \.styleOnBoardingState,
                                action: PrivacyOnBoardingAction.styleOnBoardingAction
                            ),
                            then: StyleOnBoardingView.init(store:)
                        ),
                    isActive: viewStore.binding(
                        get: \.navigateStyleOnBoarding,
                        send: PrivacyOnBoardingAction.navigationStyleOnBoarding)
                )
                
                TerciaryButtonView(
                    label: {
                        Text("OnBoarding.Skip".localized)
                            .adaptiveFont(.latoRegular, size: 16)
                        
                    }) {
                    viewStore.send(.skipAlertButtonTapped)
                }
                .padding(.horizontal, 16)
                .alert(
                    store.scope(state: \.skipAlert),
                    dismiss: .cancelSkipAlert
                )
                
                PrimaryButtonView(
                    label: {
                        Text("OnBoarding.Continue".localized)
                            .adaptiveFont(.latoRegular, size: 16)
                    }) {
                    viewStore.send(.navigationStyleOnBoarding(true))
                }
                .padding(.horizontal, 16)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}
