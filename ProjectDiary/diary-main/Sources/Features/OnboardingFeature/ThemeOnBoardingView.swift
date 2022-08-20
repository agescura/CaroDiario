//
//  ThemeOnBoardingView.swift
//  
//
//  Created by Albert Gil Escura on 17/8/21.
//

import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import Models
import EntriesFeature
import Styles
import UserDefaultsClient
import FeedbackGeneratorClient

public struct ThemeOnBoardingState: Equatable {
    public var themeType: ThemeType
    public var entries: IdentifiedArrayOf<DayEntriesRowState>
    
    public var isAppClip = false
}

public enum ThemeOnBoardingAction: Equatable {
    case themeChanged(ThemeType)
    case entries(id: UUID, action: DayEntriesRowAction)
    
    case startButtonTapped
}

public struct ThemeOnBoardingEnvironment {
    public let userDefaultsClient: UserDefaultsClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let date: () -> Date
    public let uuid: () -> UUID
    public let setUserInterfaceStyle: (UIUserInterfaceStyle) async -> Void
}

public let themeOnBoardingReducer: Reducer<
    ThemeOnBoardingState,
    ThemeOnBoardingAction,
    ThemeOnBoardingEnvironment
> = .combine(
    dayEntriesReducer
        .pullback(
            state: \DayEntriesRowState.dayEntries,
            action: /DayEntriesRowAction.dayEntry,
            environment: { _ in () }
        )
        .forEach(
            state: \ThemeOnBoardingState.entries,
            action: /ThemeOnBoardingAction.entries,
            environment: { EntriesEnvironment(
                fileClient: .noop,
                userDefaultsClient: .noop,
                avCaptureDeviceClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                avAssetClient: .noop,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                date: $0.date,
                uuid: UUID.init)
            }
        ),
    
    .init { state, action, environment in
        switch action {
        case let .themeChanged(themeChanged):
            state.themeType = themeChanged
            return .fireAndForget {
                await environment.setUserInterfaceStyle(themeChanged.userInterfaceStyle)
                await environment.feedbackGeneratorClient.selectionChanged()
            }
            
        case .entries:
            return .none
            
        case .startButtonTapped:
            return environment.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
                .fireAndForget()
        }
    }
)

public struct ThemeOnBoardingView: View {
    let store: Store<ThemeOnBoardingState, ThemeOnBoardingAction>
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {

                        Text("OnBoarding.Theme.Title".localized)
                            .adaptiveFont(.latoBold, size: 24)
                            .foregroundColor(.adaptiveBlack)
                        
                        Text("OnBoarding.Style.Message".localized)
                            .foregroundColor(.adaptiveBlack)
                            .adaptiveFont(.latoRegular, size: 10)
                        
                        Picker("",  selection: viewStore.binding(
                            get: \.themeType,
                            send: ThemeOnBoardingAction.themeChanged
                        )) {
                            ForEach(ThemeType.allCases, id: \.self) { type in
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
                                    action: ThemeOnBoardingAction.entries(id:action:)),
                                content: DayEntriesRowView.init(store:)
                            )
                        }
                        .accentColor(.chambray)
                        .animation(.default, value: UUID())
                        .disabled(true)
                        .frame(minHeight: 200)
                    }
                }
                
                PrimaryButtonView(
                    label: {
                        Text(viewStore.isAppClip ? "Instalar en App Store" : "OnBoarding.Start".localized)
                            .adaptiveFont(.latoRegular, size: 16)
                    }) {
                    viewStore.send(.startButtonTapped)
                }
                .padding(.horizontal, 16)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
}
