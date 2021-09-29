//
//  StyleOnBoardingView.swift
//  
//
//  Created by Albert Gil Escura on 16/8/21.
//

import ComposableArchitecture
import SwiftUI
import SharedViews
import SharedLocalizables
import SharedModels
import EntriesFeature
import SharedStyles
import UserDefaultsClient
import FeedbackGeneratorClient

public struct StyleOnBoardingState: Equatable {
    public var styleType: StyleType
    public var layoutType: LayoutType
    public var entries: IdentifiedArrayOf<DayEntriesRowState>
    
    public var skipAlert: AlertState<StyleOnBoardingAction>?
    public var layoutOnBoardingState: LayoutOnBoardingState? = nil
    public var navigateLayoutOnBoarding: Bool = false
}

public enum StyleOnBoardingAction: Equatable {
    case styleChanged(StyleType)
    case entries(id: UUID, action: DayEntriesRowAction)
    
    case layoutOnBoardingAction(LayoutOnBoardingAction)
    case navigationLayoutOnBoarding(Bool)
    
    case skipAlertButtonTapped
    case cancelSkipAlert
    case skipAlertAction
}

public struct StyleOnBoardingEnvironment {
    public let userDefaultsClient: UserDefaultsClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let mainRunLoop: AnySchedulerOf<RunLoop>
    public let uuid: () -> UUID
    public let setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
}

public let styleOnBoardingReducer: Reducer<StyleOnBoardingState, StyleOnBoardingAction, StyleOnBoardingEnvironment> = .combine(
    
    dayEntriesReducer
        .pullback(
            state: \DayEntriesRowState.dayEntries,
            action: /DayEntriesRowAction.dayEntry,
            environment: { _ in () }
        )
        .forEach(
            state: \StyleOnBoardingState.entries,
            action: /StyleOnBoardingAction.entries,
            environment: { EntriesEnvironment(
                coreDataClient: .noop,
                fileClient: .noop,
                userDefaultsClient: .noop,
                avCaptureDeviceClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                mainRunLoop: $0.mainRunLoop,
                uuid: UUID.init)
            }
        ),
    
    layoutOnBoardingReducer
        .optional()
        .pullback(
            state: \StyleOnBoardingState.layoutOnBoardingState,
            action: /StyleOnBoardingAction.layoutOnBoardingAction,
            environment: { LayoutOnBoardingEnvironment(
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
        case let .styleChanged(styleChanged):
            state.styleType = styleChanged
            state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)

            return .merge(
                environment.userDefaultsClient.set(styleType: styleChanged)
                    .fireAndForget(),
                environment.feedbackGeneratorClient.selectionChanged()
                    .fireAndForget()
            )
            
        case .entries:
            return .none
            
        case .layoutOnBoardingAction:
            return .none
            
        case let .navigationLayoutOnBoarding(value):
            state.navigateLayoutOnBoarding = value
            state.layoutOnBoardingState = value ? .init(
                styleType: state.styleType, layoutType: state.layoutType,
                entries: fakeEntries(
                    with: state.styleType,
                    layout: state.layoutType)) : nil
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
            return environment.feedbackGeneratorClient.selectionChanged()
                .fireAndForget()
            
        case .skipAlertAction:
            state.skipAlert = nil
            return environment.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
                .fireAndForget()
        }
    }
)

public struct StyleOnBoardingView: View {
    let store: Store<StyleOnBoardingState, StyleOnBoardingAction>
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("OnBoarding.Style.Title".localized)
                            .adaptiveFont(.latoBold, size: 24)
                            .foregroundColor(.adaptiveBlack)
                        
                        Text("OnBoarding.Style.Message".localized)
                            .foregroundColor(.adaptiveGray)
                            .adaptiveFont(.latoRegular, size: 10)
                        
                        Picker("",  selection: viewStore.binding(
                            get: \.styleType,
                            send: StyleOnBoardingAction.styleChanged
                        )) {
                            ForEach(StyleType.allCases, id: \.self) { type in
                                Text(type.rawValue.localized)
                                    .foregroundColor(.berryRed)
                                    .adaptiveFont(.latoRegular, size: 10)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEachStore(
                                store.scope(
                                    state: \.entries,
                                    action: StyleOnBoardingAction.entries(id:action:)),
                                content: DayEntriesRowView.init(store:)
                            )
                        }
                        .accentColor(.chambray)
                        .animation(.default)
                        .disabled(true)
                        .frame(minHeight: 200)
                        
                        NavigationLink(
                            "",
                            destination:
                                IfLetStore(
                                    store.scope(
                                        state: \.layoutOnBoardingState,
                                        action: StyleOnBoardingAction.layoutOnBoardingAction
                                    ),
                                    then: LayoutOnBoardingView.init(store:)
                                ),
                            isActive: viewStore.binding(
                                get: \.navigateLayoutOnBoarding,
                                send: StyleOnBoardingAction.navigationLayoutOnBoarding)
                        )
                    }
                }
                
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
                    viewStore.send(.navigationLayoutOnBoarding(true))
                }
                .padding(.horizontal, 16)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}
