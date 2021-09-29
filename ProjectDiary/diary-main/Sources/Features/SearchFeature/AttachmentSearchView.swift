//
//  AttachmentSearchView.swift
//
//  Created by Albert Gil Escura on 21/9/21.
//

import ComposableArchitecture
import SwiftUI
import EntriesFeature
import CoreDataClient
import FileClient
import UserDefaultsClient
import AVCaptureDeviceClient
import UIApplicationClient
import AVAudioPlayerClient
import AVAudioSessionClient
import AVAudioRecorderClient
import EntryDetailFeature
import SharedModels

public enum AttachmentSearchType: String {
    case images
    case videos
    case audios
}

extension AttachmentSearchType {
    var title: String {
        switch self {
        case .images:
            return "Settings.Attachment.Image".localized
        case .videos:
            return "Settings.Attachment.Video".localized
        case .audios:
            return "Settings.Attachment.Audio".localized
        }
    }
}

public struct AttachmentSearchState: Equatable {
    public var type: AttachmentSearchType
    public var entries: IdentifiedArrayOf<DayEntriesRowState>
    
    public var entryDetailState: EntryDetailState?
    public var navigateEntryDetail = false
    public var entryDetailSelected: Entry?
    
    public var entriesCount: Int {
        entries.map { $0.dayEntries.entries.count }.reduce(0, +)
    }
}

public enum AttachmentSearchAction: Equatable {
    case entries(id: UUID, action: DayEntriesRowAction)
    case remove(Entry)
    
    case entryDetailAction(EntryDetailAction)
    case navigateEntryDetail(Bool)
}

public struct AttachmentSearchEnvironment {
    public let coreDataClient: CoreDataClient
    public let fileClient: FileClient
    public let userDefaultsClient: UserDefaultsClient
    public let avCaptureDeviceClient: AVCaptureDeviceClient
    public let applicationClient: UIApplicationClient
    public let avAudioSessionClient: AVAudioSessionClient
    public let avAudioPlayerClient: AVAudioPlayerClient
    public let avAudioRecorderClient: AVAudioRecorderClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let mainRunLoop: AnySchedulerOf<RunLoop>
    public let uuid: () -> UUID
    
    public init(
        coreDataClient: CoreDataClient,
        fileClient: FileClient,
        userDefaultsClient: UserDefaultsClient,
        avCaptureDeviceClient: AVCaptureDeviceClient,
        applicationClient: UIApplicationClient,
        avAudioSessionClient: AVAudioSessionClient,
        avAudioPlayerClient: AVAudioPlayerClient,
        avAudioRecorderClient: AVAudioRecorderClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        mainRunLoop: AnySchedulerOf<RunLoop>,
        uuid: @escaping () -> UUID
    ) {
        self.coreDataClient = coreDataClient
        self.fileClient = fileClient
        self.userDefaultsClient = userDefaultsClient
        self.avCaptureDeviceClient = avCaptureDeviceClient
        self.applicationClient = applicationClient
        self.avAudioSessionClient = avAudioSessionClient
        self.avAudioPlayerClient = avAudioPlayerClient
        self.avAudioRecorderClient = avAudioRecorderClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.mainRunLoop = mainRunLoop
        self.uuid = uuid
    }
}

public let attachmentSearchReducer: Reducer<AttachmentSearchState, AttachmentSearchAction, AttachmentSearchEnvironment> = .combine(
    
    dayEntriesReducer
        .pullback(
            state: \DayEntriesRowState.dayEntries,
            action: /DayEntriesRowAction.dayEntry,
            environment: { _ in () }
        )
        .forEach(
            state: \AttachmentSearchState.entries,
            action: /AttachmentSearchAction.entries,
            environment: { AttachmentSearchEnvironment(
                coreDataClient: $0.coreDataClient,
                fileClient: $0.fileClient,
                userDefaultsClient: $0.userDefaultsClient,
                avCaptureDeviceClient: $0.avCaptureDeviceClient,
                applicationClient: $0.applicationClient,
                avAudioSessionClient: $0.avAudioSessionClient,
                avAudioPlayerClient: $0.avAudioPlayerClient,
                avAudioRecorderClient: $0.avAudioRecorderClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                mainRunLoop: $0.mainRunLoop,
                uuid: $0.uuid)
            }
        ),
    
    entryDetailReducer
        .optional()
        .pullback(
            state: \AttachmentSearchState.entryDetailState,
            action: /AttachmentSearchAction.entryDetailAction,
            environment: { EntryDetailEnvironment(
                coreDataClient: $0.coreDataClient,
                fileClient: $0.fileClient,
                avCaptureDeviceClient: $0.avCaptureDeviceClient,
                applicationClient: $0.applicationClient,
                avAudioSessionClient: $0.avAudioSessionClient,
                avAudioPlayerClient: $0.avAudioPlayerClient,
                avAudioRecorderClient: $0.avAudioRecorderClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                mainRunLoop: $0.mainRunLoop,
                uuid: $0.uuid)
            }
        ),
    
        .init { state, action, environment in
            switch action {
                
            case let .entries(id: _, action: .dayEntry(.navigateDetail(entry))):
                state.entryDetailSelected = entry
                return Effect(value: .navigateEntryDetail(true))
                
            case .entries:
                return .none
                
            case let .remove(entry):
                return environment.coreDataClient.removeEntry(entry.id)
                    .fireAndForget()
                
            case let .navigateEntryDetail(value):
                guard let entry = state.entryDetailSelected else { return .none }
                state.navigateEntryDetail = value
                state.entryDetailState = value ? .init(entry: entry) : nil
                if value == false {
                    state.entryDetailSelected = nil
                }
                return .none
                
            case let .entryDetailAction(.remove(entry)):
                return .merge(
                    environment.fileClient.removeAttachments(entry.attachments.urls, environment.backgroundQueue)
                        .receive(on: environment.mainQueue)
                        .eraseToEffect()
                        .map({ AttachmentSearchAction.remove(entry) }),
                    Effect(value: .navigateEntryDetail(false))
                )
                
            case .entryDetailAction:
                return .none
            }
        }
)

public struct AttachmentSearchView: View {
    let store: Store<AttachmentSearchState, AttachmentSearchAction>
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 16) {
                    
                    if !viewStore.entries.isEmpty {
                        Text("\("Settings.Results".localized) \(viewStore.entriesCount)")
                            .foregroundColor(.chambray)
                            .adaptiveFont(.latoRegular, size: 10)
                            .padding(.leading)
                    } else {
                        Text("Search.Empty".localized)
                            .foregroundColor(.chambray)
                            .adaptiveFont(.latoRegular, size: 10)
                    }
                    
                    ZStack {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEachStore(
                                store.scope(
                                    state: \.entries,
                                    action: AttachmentSearchAction.entries(id:action:)),
                                content: DayEntriesRowView.init(store:)
                            )
                        }
                        
                        
                        
                        NavigationLink(
                            "", destination: IfLetStore(
                                store.scope(
                                    state: \.entryDetailState,
                                    action: AttachmentSearchAction.entryDetailAction
                                ),
                                then: EntryDetailView.init(store:)
                            ),
                            isActive: viewStore.binding(
                                get: \.navigateEntryDetail,
                                send: AttachmentSearchAction.navigateEntryDetail)
                        )
                    }
                }
                .padding(.top, 16)
            }
            .navigationBarTitle(viewStore.type.title, displayMode: .inline)
        }
    }
}
