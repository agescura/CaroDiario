//
//  AppearanceOnBoardingView.swift
//  
//
//  Created by Albert Gil Escura on 27/7/21.
//

import ComposableArchitecture
import SwiftUI
import EntriesFeature
import SharedViews
import SharedStyles
import UserDefaultsClient
import FeedbackGeneratorClient

public struct LayoutOnBoardingState: Equatable {
    public var styleType: StyleType
    public var layoutType: LayoutType
    public var entries: IdentifiedArrayOf<DayEntriesRowState>
    
    public var skipAlert: AlertState<LayoutOnBoardingAction>?
    public var themeOnBoardingState: ThemeOnBoardingState? = nil
    public var navigateThemeOnBoarding: Bool = false
    
    public var isAppClip = false
}

public enum LayoutOnBoardingAction: Equatable {
    case layoutChanged(LayoutType)
    case entries(id: UUID, action: DayEntriesRowAction)
    
    case themeOnBoardingAction(ThemeOnBoardingAction)
    case navigateThemeOnBoarding(Bool)
    
    case skipAlertButtonTapped
    case cancelSkipAlert
    case skipAlertAction
}

public struct LayoutOnBoardingEnvironment {
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

public let layoutOnBoardingReducer: Reducer<LayoutOnBoardingState, LayoutOnBoardingAction, LayoutOnBoardingEnvironment> = .combine(
    
    dayEntriesReducer
        .pullback(
            state: \DayEntriesRowState.dayEntries,
            action: /DayEntriesRowAction.dayEntry,
            environment: { _ in () }
        )
        .forEach(
            state: \LayoutOnBoardingState.entries,
            action: /LayoutOnBoardingAction.entries,
            environment: { EntriesEnvironment(
                fileClient: .noop,
                userDefaultsClient: $0.userDefaultsClient,
                avCaptureDeviceClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                avAssetClient: .noop,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                mainRunLoop: $0.mainRunLoop,
                uuid: UUID.init)
            }
        ),
    
    themeOnBoardingReducer
        .optional()
        .pullback(
            state: \LayoutOnBoardingState.themeOnBoardingState,
            action: /LayoutOnBoardingAction.themeOnBoardingAction,
            environment: { ThemeOnBoardingEnvironment(
                userDefaultsClient: $0.userDefaultsClient,
                feedbackGeneratorClient: $0.feedbackGeneratorClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: .main,
                mainRunLoop: $0.mainRunLoop,
                uuid: $0.uuid,
                setUserInterfaceStyle: $0.setUserInterfaceStyle)
            }
        ),
    
    .init { state, action, environment in
        switch action {
        case let .layoutChanged(layoutChanged):
            state.layoutType = layoutChanged
            state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
            
            return .merge(
                environment.userDefaultsClient.set(layoutType: layoutChanged)
                    .fireAndForget(),
                environment.feedbackGeneratorClient.selectionChanged()
                    .fireAndForget()
            )
            
        case .entries:
            return .none
            
        case .themeOnBoardingAction:
            return .none
            
        case let .navigateThemeOnBoarding(value):
            state.navigateThemeOnBoarding = value
            let themeType = environment.userDefaultsClient.themeType
            state.themeOnBoardingState = value ? .init(
                themeType: themeType,
                entries: fakeEntries(with: environment.userDefaultsClient.styleType,
                                     layout: environment.userDefaultsClient.layoutType),
                isAppClip: state.isAppClip) : nil
            return environment.setUserInterfaceStyle(themeType.userInterfaceStyle).fireAndForget()
            
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

public struct LayoutOnBoardingView: View {
    let store: Store<LayoutOnBoardingState, LayoutOnBoardingAction>
    
    public init(
        store: Store<LayoutOnBoardingState, LayoutOnBoardingAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("OnBoarding.Layout.Title".localized)
                            .adaptiveFont(.latoBold, size: 24)
                            .foregroundColor(.adaptiveBlack)
                        
                        Text("OnBoarding.Appearance.Message".localized)
                            .adaptiveFont(.latoItalic, size: 10)
                            .foregroundColor(.adaptiveGray)
                        
                        
                        Picker("",  selection: viewStore.binding(
                            get: \.layoutType,
                            send: LayoutOnBoardingAction.layoutChanged
                        )) {
                            ForEach(LayoutType.allCases, id: \.self) { type in
                                Text(type.rawValue.localized)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEachStore(
                                store.scope(
                                    state: \.entries,
                                    action: LayoutOnBoardingAction.entries(id:action:)),
                                content: DayEntriesRowView.init(store:)
                            )
                        }
                        .accentColor(.chambray)
                        .animation(.default, value: UUID())
                        .disabled(true)
                        .frame(minHeight: 200)
                        
                        NavigationLink(
                            "",
                            destination:
                                IfLetStore(
                                    store.scope(
                                        state: \.themeOnBoardingState,
                                        action: LayoutOnBoardingAction.themeOnBoardingAction
                                    ),
                                    then: ThemeOnBoardingView.init(store:)
                                ),
                            isActive: viewStore.binding(
                                get: \.navigateThemeOnBoarding,
                                send: LayoutOnBoardingAction.navigateThemeOnBoarding)
                        )
                        .frame(height: 0)
                        
                    }
                }
                
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
                    viewStore.send(.navigateThemeOnBoarding(true))
                }
                .padding(.horizontal, 16)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}
