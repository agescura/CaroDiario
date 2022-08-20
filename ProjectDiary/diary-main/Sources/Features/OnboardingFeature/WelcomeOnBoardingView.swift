//
//  WelcomeOnBoardingView.swift
//  
//
//  Created by Albert Gil Escura on 18/7/21.
//

import SwiftUI
import ComposableArchitecture
import Views
import UserDefaultsClient
import FeedbackGeneratorClient

public struct WelcomeOnBoardingState: Equatable {
    public var privacyOnBoardingState: PrivacyOnBoardingState?
    public var navigatePrivacyOnBoarding: Bool = false
    
    public var skipAlert: AlertState<WelcomeOnBoardingAction>?
    public var selectedPage = 0
    public var tabViewAnimated = false
    
    public var isAppClip = false
    
    public init(
        privacyOnBoardingState: PrivacyOnBoardingState? = nil,
        navigatePrivacyOnBoarding: Bool = false,
        isAppClip: Bool = false
    ) {
        self.privacyOnBoardingState = privacyOnBoardingState
        self.navigatePrivacyOnBoarding = navigatePrivacyOnBoarding
        self.isAppClip = isAppClip
    }
}

public enum WelcomeOnBoardingAction: Equatable {
    case privacyOnBoardingAction(PrivacyOnBoardingAction)
    case navigationPrivacyOnBoarding(Bool)
    
    case skipAlertButtonTapped
    case cancelSkipAlert
    case skipAlertAction
    
    case selectedPage(Int)
    case startTimer
    case nextPage
}

public struct WelcomeOnBoardingEnvironment {
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

public let welcomeOnBoardingReducer: Reducer<WelcomeOnBoardingState, WelcomeOnBoardingAction, WelcomeOnBoardingEnvironment> = .combine(
    
    privacyOnBoardingReducer
        .optional()
        .pullback(
            state: \WelcomeOnBoardingState.privacyOnBoardingState,
            action: /WelcomeOnBoardingAction.privacyOnBoardingAction,
            environment: { PrivacyOnBoardingEnvironment(
                userDefaultsClient: $0.userDefaultsClient,
                feedbackGeneratorClient: $0.feedbackGeneratorClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                date: $0.date,
                uuid: UUID.init,
                setUserInterfaceStyle: $0.setUserInterfaceStyle)
            }
        ),
    
    .init { state, action, environment in
        struct TimerId: Hashable {}
        
        switch action {
        
        case let .navigationPrivacyOnBoarding(value):
            state.privacyOnBoardingState = value ? .init(isAppClip: state.isAppClip) : nil
            state.navigatePrivacyOnBoarding = value
            return .cancel(id: TimerId())
            
        case .privacyOnBoardingAction:
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
            return .merge(
                environment.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
                    .fireAndForget(),
                .cancel(id: TimerId())
            )
            
        case .startTimer:
            return Effect.timer(id: TimerId(), every: 5.0, on: environment.mainQueue)
                .map { _ in .nextPage }
            
        case let .selectedPage(value):
            state.selectedPage = value
            return Effect.timer(id: TimerId(), every: 5.0, on: environment.mainQueue)
                .map { _ in .nextPage }
            
        case .nextPage:
            state.tabViewAnimated = true
            if state.selectedPage == 2 {
                state.selectedPage = 0
            } else {
                state.selectedPage += 1
            }
            return .none
        }
    }
)

public struct WelcomeOnBoardingView: View {
    let store: Store<WelcomeOnBoardingState, WelcomeOnBoardingAction>
    
    public init(
        store: Store<WelcomeOnBoardingState, WelcomeOnBoardingAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("OnBoarding.Diary".localized)
                        .adaptiveFont(.latoBold, size: 24)
                        .foregroundColor(.adaptiveBlack)
                    Text("OnBoarding.Welcome".localized)
                        .adaptiveFont(.latoItalic, size: 12)
                        .foregroundColor(.adaptiveGray)
                    
                    
                    OnBoardingTabView(
                        items: [
                            .init(id: 0, title: "OnBoarding.Description.1".localized),
                            .init(id: 1, title: "OnBoarding.Description.2".localized),
                            .init(id: 2, title: "OnBoarding.Description.3".localized)
                        ],
                        selection: viewStore.binding(get: \.selectedPage, send: WelcomeOnBoardingAction.selectedPage),
                        animated: viewStore.tabViewAnimated
                    )
                    .frame(minHeight: 150)
                    
                    NavigationLink(
                        "",
                        destination:
                            IfLetStore(
                                store.scope(
                                    state: \.privacyOnBoardingState,
                                    action: WelcomeOnBoardingAction.privacyOnBoardingAction
                                ),
                                then: PrivacyOnBoardingView.init(store:)
                            ),
                        isActive: viewStore.binding(
                            get: \.navigatePrivacyOnBoarding,
                            send: WelcomeOnBoardingAction.navigationPrivacyOnBoarding)
                    )
                    
                    TerciaryButtonView(
                        label: {
                            Text("OnBoarding.Skip".localized)
                                .adaptiveFont(.latoRegular, size: 16)
                            
                        }) {
                        viewStore.send(.skipAlertButtonTapped)
                    }
                    .opacity(viewStore.isAppClip ? 0.0 : 1.0)
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
                        viewStore.send(.navigationPrivacyOnBoarding(true))
                    }
                    .padding(.horizontal, 16)
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                viewStore.send(.startTimer)
            }
        }
    }
}
