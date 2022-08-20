//
//  HomeView.swift
//  HomeFeature
//
//  Created by Albert Gil Escura on 26/6/21.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import CoreDataClient
import FileClient
import EntriesFeature
import SettingsFeature
import AddEntryFeature
import Models
import LocalAuthenticationClient
import UIApplicationClient
import AVCaptureDeviceClient
import FeedbackGeneratorClient
import SearchFeature
import AVAudioSessionClient
import AVAudioPlayerClient
import AVAudioRecorderClient
import StoreKitClient
import PDFKitClient
import AVAssetClient

public struct HomeState: Equatable {
    public var tabBars: [TabViewType]
    public var selectedTabBar: TabViewType
    public var entriesState: EntriesState
    public var searchState: SearchState
    public var settings: SettingsState
    
    public init(
        tabBars: [TabViewType],
        entriesState: EntriesState,
        searchState: SearchState,
        settings: SettingsState,
        selectedTabBar: TabViewType = .entries
    ) {
        self.tabBars = tabBars
        self.entriesState = entriesState
        self.searchState = searchState
        self.settings = settings
        self.selectedTabBar = selectedTabBar
    }
}

public enum HomeAction: Equatable {
    case tabBarSelected(TabViewType)
    case starting
    case entries(EntriesAction)
    case search(SearchAction)
    case settings(SettingsAction)
}

public struct HomeEnvironment {
    public let fileClient: FileClient
    public let userDefaultsClient: UserDefaultsClient
    public let localAuthenticationClient: LocalAuthenticationClient
    public let applicationClient: UIApplicationClient
    public let avCaptureDeviceClient: AVCaptureDeviceClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let avAudioSessionClient: AVAudioSessionClient
    public let avAudioPlayerClient: AVAudioPlayerClient
    public let avAudioRecorderClient: AVAudioRecorderClient
    public let pdfKitClient: PDFKitClient
    public let avAssetClient: AVAssetClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let storeKitClient: StoreKitClient
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let date: () -> Date
    public let uuid: () -> UUID
    public let setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
    
    public init(
        fileClient: FileClient,
        userDefaultsClient: UserDefaultsClient,
        localAuthenticationClient: LocalAuthenticationClient,
        applicationClient:  UIApplicationClient,
        avCaptureDeviceClient: AVCaptureDeviceClient,
        feedbackGeneratorClient: FeedbackGeneratorClient,
        avAudioSessionClient: AVAudioSessionClient,
        avAudioPlayerClient: AVAudioPlayerClient,
        avAudioRecorderClient: AVAudioRecorderClient,
        storeKitClient: StoreKitClient,
        pdfKitClient: PDFKitClient,
        avAssetClient: AVAssetClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        date: @escaping () -> Date,
        uuid: @escaping () -> UUID,
        setUserInterfaceStyle: @escaping (UIUserInterfaceStyle) -> Effect<Never, Never>
    ) {
        self.fileClient = fileClient
        self.userDefaultsClient = userDefaultsClient
        self.localAuthenticationClient = localAuthenticationClient
        self.applicationClient = applicationClient
        self.avCaptureDeviceClient = avCaptureDeviceClient
        self.feedbackGeneratorClient = feedbackGeneratorClient
        self.avAudioSessionClient = avAudioSessionClient
        self.avAudioPlayerClient = avAudioPlayerClient
        self.avAudioRecorderClient = avAudioRecorderClient
        self.storeKitClient = storeKitClient
        self.pdfKitClient = pdfKitClient
        self.avAssetClient = avAssetClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.date = date
        self.uuid = uuid
        self.setUserInterfaceStyle = setUserInterfaceStyle
    }
}

public let homeReducer: Reducer<
    HomeState,
    HomeAction,
    HomeEnvironment
> = .combine(
    
    entriesReducer.pullback(
        state: \HomeState.entriesState,
        action: /HomeAction.entries,
        environment: {
            EntriesEnvironment(
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
                date: $0.date,
                uuid: UUID.init
            )
        }
    ),
    
    searchReducer.pullback(
        state: \HomeState.searchState,
        action: /HomeAction.search,
        environment: {
            SearchEnvironment(
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
                date: $0.date,
                uuid: $0.uuid
            )
        }
    ),
    
    settingsReducer.pullback(
        state: \HomeState.settings,
        action: /HomeAction.settings,
        environment: {
            SettingsEnvironment(
                fileClient: $0.fileClient,
                localAuthenticationClient: $0.localAuthenticationClient,
                applicationClient: $0.applicationClient,
                avCaptureDeviceClient: $0.avCaptureDeviceClient,
                feedbackGeneratorClient: $0.feedbackGeneratorClient,
                avAudioSessionClient: $0.avAudioSessionClient,
                storeKitClient: $0.storeKitClient,
                pdfKitClient: $0.pdfKitClient,
                mainQueue: $0.mainQueue,
                date: $0.date,
                setUserInterfaceStyle: $0.setUserInterfaceStyle
            )
        }
    ),
    
        .init { state, action, environment in
            switch action {
                
            case let .tabBarSelected(tab):
                state.selectedTabBar = tab
                return .none
                
            case .starting, .entries, .settings, .search:
                return .none
            }
        }
)

public struct HomeView: View {
    let store: Store<HomeState, HomeAction>
    
    public init(
        store: Store<HomeState, HomeAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            TabView(
                selection: viewStore.binding(
                    get: { $0.selectedTabBar },
                    send: HomeAction.tabBarSelected)
            ) {
                ForEach(viewStore.tabBars, id: \.self) { type in
                    type.view(for: store)
                        .tabItem {
                            VStack {
                                Image(systemName: type.icon)
                                Text(type.rawValue)
                            }
                        }
                }
            }
            .accentColor(.chambray)
        }
        .accentColor(.chambray)
    }
}

extension TabViewType {
    
    @ViewBuilder
    func view(for store: Store<HomeState, HomeAction>) -> some View {
        switch self {
            
        case .entries:
            EntriesView(
                store: store.scope(
                    state: \.entriesState,
                    action: HomeAction.entries
                )
            )
            
        case .search:
            SearchView(
                store: store.scope(
                    state: \.searchState,
                    action: HomeAction.search
                )
            )
            
        case .settings:
            SettingsView(
                store: store.scope(
                    state: \.settings,
                    action: HomeAction.settings
                )
            )
        }
    }
}
