//
//  SearchView.swift  
//
//  Created by Albert Gil Escura on 24/8/21.
//

import ComposableArchitecture
import SwiftUI
import SharedModels
import CoreDataClient
import EntriesFeature
import FileClient
import UserDefaultsClient
import AVCaptureDeviceClient
import UIApplicationClient
import AVAudioPlayerClient
import AVAudioSessionClient
import AVAudioRecorderClient
import EntryDetailFeature
import AVAssetClient

public struct SearchState: Equatable {
    public var searchText: String = ""
    public var entries: IdentifiedArrayOf<DayEntriesRowState>
    
    public var attachmentSearchState: AttachmentSearchState?
    public var navigateAttachmentSearch = false
    
    public var entryDetailState: EntryDetailState?
    public var navigateEntryDetail = false
    public var entryDetailSelected: Entry?
    
    public var entriesCount: Int {
        entries.map(\.dayEntries.entries.count).reduce(0, +)
    }
    
    public init(
        searchText: String,
        entries: IdentifiedArrayOf<DayEntriesRowState>
    ) {
        self.searchText = searchText
        self.entries = entries
    }
}

public enum SearchAction: Equatable {
    case searching(newText: String)
    case searchResponse([[Entry]])
    case entries(id: UUID, action: DayEntriesRowAction)
    case remove(Entry)
    
    case attachmentSearchAction(AttachmentSearchAction)
    case navigateAttachmentSearch(Bool)
    case navigateImageSearch
    case navigateVideoSearch
    case navigateAudioSearch
    case navigateSearch(AttachmentSearchType, [[Entry]])
    
    case entryDetailAction(EntryDetailAction)
    case navigateEntryDetail(Bool)
}

public struct SearchEnvironment {
    public let coreDataClient: CoreDataClient
    public let fileClient: FileClient
    public let userDefaultsClient: UserDefaultsClient
    public let avCaptureDeviceClient: AVCaptureDeviceClient
    public let applicationClient: UIApplicationClient
    public let avAudioSessionClient: AVAudioSessionClient
    public let avAudioPlayerClient: AVAudioPlayerClient
    public let avAudioRecorderClient: AVAudioRecorderClient
    public let avAssetClient: AVAssetClient
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
        avAssetClient: AVAssetClient,
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
        self.avAssetClient = avAssetClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.mainRunLoop = mainRunLoop
        self.uuid = uuid
    }
}

public let searchReducer: Reducer<SearchState, SearchAction, SearchEnvironment> = .combine(
    
    dayEntriesReducer
        .pullback(
            state: \DayEntriesRowState.dayEntries,
            action: /DayEntriesRowAction.dayEntry,
            environment: { _ in () }
        )
        .forEach(
            state: \SearchState.entries,
            action: /SearchAction.entries,
            environment: { SearchEnvironment(
                coreDataClient: $0.coreDataClient,
                fileClient: $0.fileClient,
                userDefaultsClient: $0.userDefaultsClient,
                avCaptureDeviceClient: $0.avCaptureDeviceClient,
                applicationClient: $0.applicationClient,
                avAudioSessionClient: $0.avAudioSessionClient,
                avAudioPlayerClient: $0.avAudioPlayerClient,
                avAudioRecorderClient: $0.avAudioRecorderClient,
                avAssetClient: $0.avAssetClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                mainRunLoop: $0.mainRunLoop,
                uuid: $0.uuid)
            }
        ),
    
    attachmentSearchReducer
        .optional()
        .pullback(
            state: \SearchState.attachmentSearchState,
            action: /SearchAction.attachmentSearchAction,
            environment: { AttachmentSearchEnvironment(
                coreDataClient: $0.coreDataClient,
                fileClient: $0.fileClient,
                userDefaultsClient: $0.userDefaultsClient,
                avCaptureDeviceClient: $0.avCaptureDeviceClient,
                applicationClient: $0.applicationClient,
                avAudioSessionClient: $0.avAudioSessionClient,
                avAudioPlayerClient: $0.avAudioPlayerClient,
                avAudioRecorderClient: $0.avAudioRecorderClient,
                avAssetClient: $0.avAssetClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                mainRunLoop: $0.mainRunLoop,
                uuid: $0.uuid)
            }
        ),
    
    .init { state, action, environment in
        
        switch action {
        case let .searching(newText: newText):
            state.searchText = newText
            return environment.coreDataClient.searchEntries(newText)
                .map(SearchAction.searchResponse)
            
        case let .searchResponse(response):
            var dayResult: IdentifiedArrayOf<DayEntriesRowState> = []
            
            for entries in response {
                let day = DayEntriesRowState(dayEntry: .init(
                    entry: .init(uniqueElements: entries), style: environment.userDefaultsClient.styleType, layout: environment.userDefaultsClient.layoutType), id: environment.uuid())
                dayResult.append(day)
            }
            state.entries = dayResult
            return .none
            
        case let .entries(id: _, action: .dayEntry(.navigateDetail(entry))):
            state.entryDetailSelected = entry
            return Effect(value: .navigateEntryDetail(true))
            
        case .entries:
            return .none
            
        case .attachmentSearchAction:
            return .none
            
        case let .navigateAttachmentSearch(value):
            state.attachmentSearchState = value ? .init(type: .images, entries: []) : nil
            state.navigateAttachmentSearch = value
            return .none
            
        case .navigateImageSearch:
            return environment.coreDataClient.searchImageEntries()
                .map({ SearchAction.navigateSearch(.images, $0) })
            
        case .navigateVideoSearch:
            return environment.coreDataClient.searchVideoEntries()
                .map({ SearchAction.navigateSearch(.videos, $0) })
            
        case .navigateAudioSearch:
            return environment.coreDataClient.searchAudioEntries()
                .map({ SearchAction.navigateSearch(.audios, $0) })
            
        case let .navigateSearch(type, response):
            var dayResult: IdentifiedArrayOf<DayEntriesRowState> = []
            
            for entries in response {
                let day = DayEntriesRowState(dayEntry: .init(
                    entry: .init(uniqueElements: entries), style: environment.userDefaultsClient.styleType, layout: environment.userDefaultsClient.layoutType), id: environment.uuid())
                dayResult.append(day)
            }
            
            state.attachmentSearchState = .init(type: type, entries: dayResult)
            state.navigateAttachmentSearch = true
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
                    .map({ SearchAction.remove(entry) }),
                Effect(value: .navigateEntryDetail(false))
            )
            
        case .entryDetailAction:
            return .none
        }
    }
)

public struct SearchView: View {
    let store: Store<SearchState, SearchAction>
    @ObservedObject var searchBar = SearchBar()
    
    public init(
        store: Store<SearchState, SearchAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    VStack {
                        if viewStore.searchText.isEmpty {
                            VStack(spacing: 16) {
                                
                                HStack(spacing: 16) {
                                    Text(AttachmentSearchType.images.title)
                                        .foregroundColor(.adaptiveGray)
                                        .adaptiveFont(.latoRegular, size: 10)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.adaptiveGray)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewStore.send(.navigateImageSearch)
                                }
                                
                                Divider()
                                
                                HStack(spacing: 16) {
                                    Text(AttachmentSearchType.videos.title)
                                        .foregroundColor(.adaptiveGray)
                                        .adaptiveFont(.latoRegular, size: 10)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.adaptiveGray)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewStore.send(.navigateVideoSearch)
                                }
                                
                                Divider()
                                
                                HStack(spacing: 16) {
                                    Text(AttachmentSearchType.audios.title)
                                        .foregroundColor(.adaptiveGray)
                                        .adaptiveFont(.latoRegular, size: 10)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.adaptiveGray)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewStore.send(.navigateAudioSearch)
                                }
                                
                                Divider()
                                
                                Spacer()
                            }
                            .padding()
                        } else if viewStore.entries.isEmpty {
                            Text("Search.Empty".localized)
                                .foregroundColor(.chambray)
                                .adaptiveFont(.latoRegular, size: 10)
                        }
                        
                        if !viewStore.entries.isEmpty {
                            ScrollView(.vertical) {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("\("Search.Results".localized)\(viewStore.entriesCount)")
                                        .foregroundColor(.chambray)
                                        .adaptiveFont(.latoRegular, size: 10)
                                        .padding(.leading)
                                    
                                    LazyVStack(alignment: .leading, spacing: 8) {
                                        ForEachStore(
                                            store.scope(
                                                state: \.entries,
                                                action: SearchAction.entries(id:action:)),
                                            content: DayEntriesRowView.init(store:)
                                        )
                                    }
                                }
                                .padding(.top, 16)
                            }
                        }
                    }
                    
                    NavigationLink(
                        "",
                        destination:
                            IfLetStore(
                                store.scope(
                                    state: \.entryDetailState,
                                    action: SearchAction.entryDetailAction
                                ),
                                then: EntryDetailView.init(store:)
                            ),
                        isActive: viewStore.binding(
                            get: \.navigateEntryDetail,
                            send: SearchAction.navigateEntryDetail)
                    )
                    
                    NavigationLink(
                        "",
                        destination:
                            IfLetStore(
                                store.scope(
                                    state: \.attachmentSearchState,
                                    action: SearchAction.attachmentSearchAction
                                ),
                                then: AttachmentSearchView.init(store:)
                            ),
                        isActive: viewStore.binding(
                            get: \.navigateAttachmentSearch,
                            send: SearchAction.navigateAttachmentSearch)
                    )
                }
                .navigationBarTitle("Search.Title".localized)
                .add(searchBar) {
                    viewStore.send(.searching(newText: $0))
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
