//
//  AppearanceView.swift
//  
//
//  Created by Albert Gil Escura on 16/8/21.
//

import ComposableArchitecture
import SwiftUI
import SharedStyles
import EntriesFeature
import FeedbackGeneratorClient

public struct LayoutState: Equatable {
    public var layoutType: LayoutType
    public var styleType: StyleType
    public var entries: IdentifiedArrayOf<DayEntriesRowState>
}

public enum LayoutAction: Equatable {
    case layoutChanged(LayoutType)
    case entries(id: UUID, action: DayEntriesRowAction)
}

public struct LayoutEnvironment {
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let mainRunLoop: AnySchedulerOf<RunLoop>
}

public let layoutReducer: Reducer<LayoutState, LayoutAction, LayoutEnvironment> = .combine(
    
    dayEntriesReducer
        .pullback(
            state: \DayEntriesRowState.dayEntries,
            action: /DayEntriesRowAction.dayEntry,
            environment: { _ in () }
        )
        .forEach(
            state: \LayoutState.entries,
            action: /LayoutAction.entries,
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
                mainRunLoop: $0.mainRunLoop,
                uuid: UUID.init)
            }
        ),
    
    .init { state, action, environment in
        switch action {
        
        case let .layoutChanged(appearanceChanged):
            state.layoutType = appearanceChanged
            state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
            
            return environment.feedbackGeneratorClient.selectionChanged()
                .fireAndForget()
            
        case .entries:
            return .none
        }
    }
)

public struct LayoutView: View {
    let store: Store<LayoutState, LayoutAction>

    public var body: some View {
        WithViewStore(store) { viewStore in
            
            VStack(alignment: .leading, spacing: 16) {
                
                Picker("",  selection: viewStore.binding(
                    get: \.layoutType,
                    send: LayoutAction.layoutChanged
                )) {
                    ForEach(LayoutType.allCases, id: \.self) { type in
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
                                action: LayoutAction.entries(id:action:)),
                            content: DayEntriesRowView.init(store:)
                        )
                    }
                    .accentColor(.chambray)
                    .animation(.default, value: UUID())
                    .disabled(true)
                }
                
                Spacer()
            }
            .padding(16)
            .navigationBarTitle("Settings.Layout".localized)
        }
    }
}
