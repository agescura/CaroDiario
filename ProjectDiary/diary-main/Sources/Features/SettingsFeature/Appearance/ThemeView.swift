//
//  ThemeView.swift
//  
//
//  Created by Albert Gil Escura on 15/8/21.
//

import ComposableArchitecture
import SwiftUI
import SharedStyles
import UserDefaultsClient
import EntriesFeature
import FeedbackGeneratorClient

public struct ThemeState: Equatable {
    public var themeType: ThemeType = .system
    public var entries: IdentifiedArrayOf<DayEntriesRowState>
}

public enum ThemeAction: Equatable {
    case themeChanged(ThemeType)
    case entries(id: UUID, action: DayEntriesRowAction)
}

public struct ThemeEnvironment {
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let mainRunLoop: AnySchedulerOf<RunLoop>
}

public let themeReducer: Reducer<ThemeState, ThemeAction, ThemeEnvironment> = .combine(

    dayEntriesReducer
        .pullback(
            state: \DayEntriesRowState.dayEntries,
            action: /DayEntriesRowAction.dayEntry,
            environment: { _ in () }
        )
        .forEach(
            state: \ThemeState.entries,
            action: /ThemeAction.entries,
            environment: { EntriesEnvironment(
                coreDataClient: .noop,
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
                mainRunLoop: $0.mainRunLoop,
                uuid: UUID.init)
            }
        ),
    
    .init { state, action, environment in
        switch action {
        
        case let .themeChanged(newTheme):
            state.themeType = newTheme
            return environment.feedbackGeneratorClient.selectionChanged()
                .fireAndForget()
            
        case .entries:
            return .none
        }
    }
)

public struct ThemeView: View {
    let store: Store<ThemeState, ThemeAction>
    
    init(
        store: Store<ThemeState, ThemeAction>
    ) {
        self.store = store
        
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.chambray)
        UISegmentedControl.appearance().backgroundColor = UIColor(.adaptiveGray).withAlphaComponent(0.1)
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                
                Picker("",  selection: viewStore.binding(
                    get: \.themeType,
                    send: ThemeAction.themeChanged
                )) {
                    ForEach(ThemeType.allCases, id: \.self) { type in
                        Text(type.rawValue.localized)
                            .foregroundColor(.berryRed)
                            .adaptiveFont(.latoRegular, size: 10)
                    }
                }
                .frame(height: 60)
                .pickerStyle(SegmentedPickerStyle())
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEachStore(
                            store.scope(
                                state: \.entries,
                                action: ThemeAction.entries(id:action:)),
                            content: DayEntriesRowView.init(store:)
                        )
                    }
                    .accentColor(.chambray)
                    .animation(.default)
                    .disabled(true)
                }
                
                Spacer()
            }
            .padding(16)
            .navigationBarTitle("Settings.Theme".localized)
        }
    }
}
