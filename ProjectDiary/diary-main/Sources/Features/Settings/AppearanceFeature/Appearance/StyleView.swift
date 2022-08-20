//
//  StyleView.swift
//  
//
//  Created by Albert Gil Escura on 16/8/21.
//

import ComposableArchitecture
import SwiftUI
import Styles
import EntriesFeature
import Models
import FeedbackGeneratorClient

public struct StyleState: Equatable {
    public var styleType: StyleType
    public var layoutType: LayoutType
    public var entries: IdentifiedArrayOf<DayEntriesRowState>
}

public enum StyleAction: Equatable {
    case styleChanged(StyleType)
    case entries(id: UUID, action: DayEntriesRowAction)
}

public struct StyleEnvironment {
    public let feedbackGeneratorClient: FeedbackGeneratorClient
}

public let styleReducer: Reducer<
    StyleState,
    StyleAction,
    StyleEnvironment
> = .combine(
    dayEntriesReducer
        .pullback(
            state: \DayEntriesRowState.dayEntries,
            action: /DayEntriesRowAction.dayEntry,
            environment: { _ in () }
        )
        .forEach(
            state: \StyleState.entries,
            action: /StyleAction.entries,
            environment: { _ in
                EntriesEnvironment(
                    fileClient: .noop,
                    userDefaultsClient: .noop,
                    avCaptureDeviceClient: .noop,
                    applicationClient: .noop,
                    avAudioSessionClient: .noop,
                    avAudioPlayerClient: .noop,
                    avAudioRecorderClient: .noop,
                    avAssetClient: .noop,
                    mainQueue: .unimplemented,
                    backgroundQueue: .unimplemented,
                    date: Date.init,
                    uuid: UUID.init
                )
            }
        ),
    
    .init { state, action, environment in
        switch action {
        
        case let .styleChanged(styleChanged):
            state.styleType = styleChanged
            state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
            
            return environment.feedbackGeneratorClient.selectionChanged()
                .fireAndForget()
            
        case .entries:
            return .none
        }
    }
)

public struct StyleView: View {
    let store: Store<StyleState, StyleAction>
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(alignment: .leading, spacing: 16) {
                
                Picker("",  selection: viewStore.binding(
                    get: \.styleType,
                    send: StyleAction.styleChanged
                )) {
                    ForEach(StyleType.allCases, id: \.self) { type in
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
                                action: StyleAction.entries(id:action:)),
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
            .navigationBarTitle("Settings.Style".localized)
        }
    }
}
