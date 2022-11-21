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
import Styles
import EntryDetailFeature

public struct SharedState: Equatable {
  public var isLoading: Bool = true
  public var entries: IdentifiedArrayOf<DayEntriesRow.State> = []
  public var addEntryState: AddEntry.State?
  public var presentAddEntry = false
  public var entryDetailState: EntryDetail.State?
  public var navigateEntryDetail = false
  public var entryDetailSelected: Entry?
  
  public var search: Search.State = Search.State()
  
  public var showSplash: Bool
  public var styleType: StyleType
  public var layoutType: LayoutType
  public var themeType: ThemeType
  public var iconAppType: IconAppType
  public var language: Localizable
  public var authenticationType: LocalAuthenticationType = .none
  public var hasPasscode: Bool
  public var cameraStatus: AuthorizedVideoStatus
  public var microphoneStatus: AudioRecordPermission
  public var optionTimeForAskPasscode: Int
  public var faceIdEnabled: Bool
  public var route: Settings.State.Route? = nil
  
  public init(
    showSplash: Bool,
    styleType: StyleType,
    layoutType: LayoutType,
    themeType: ThemeType,
    iconAppType: IconAppType,
    language: Localizable,
    hasPasscode: Bool,
    cameraStatus: AuthorizedVideoStatus,
    microphoneStatus: AudioRecordPermission,
    optionTimeForAskPasscode: Int,
    faceIdEnabled: Bool
  ) {
    self.showSplash = showSplash
    self.styleType = styleType
    self.layoutType = layoutType
    self.themeType = themeType
    self.iconAppType = iconAppType
    self.language = language
    self.hasPasscode = hasPasscode
    self.cameraStatus = cameraStatus
    self.microphoneStatus = microphoneStatus
    self.optionTimeForAskPasscode = optionTimeForAskPasscode
    self.faceIdEnabled = faceIdEnabled
  }
}

public struct HomeState: Equatable {
  public var tabBars: [TabViewType]
  public var selectedTabBar: TabViewType
  public var sharedState: SharedState
  
  public var entriesState: EntriesState {
    get {
      .init(
        isLoading: self.sharedState.isLoading,
        entries: self.sharedState.entries,
        addEntryState: self.sharedState.addEntryState,
        presentAddEntry: self.sharedState.presentAddEntry,
        entryDetailState: self.sharedState.entryDetailState,
        navigateEntryDetail: self.sharedState.navigateEntryDetail,
        entryDetailSelected: self.sharedState.entryDetailSelected
      )
    }
    set {
      self.sharedState.isLoading = newValue.isLoading
      self.sharedState.entries = newValue.entries
      self.sharedState.addEntryState = newValue.addEntryState
      self.sharedState.presentAddEntry = newValue.presentAddEntry
      self.sharedState.entryDetailState = newValue.entryDetailState
      self.sharedState.navigateEntryDetail = newValue.navigateEntryDetail
      self.sharedState.entryDetailSelected = newValue.entryDetailSelected
    }
  }
  public var search: Search.State {
    get { self.sharedState.search }
    set { self.sharedState.search = newValue }
  }
  public var settings: Settings.State {
    get {
      .init(
        showSplash: self.sharedState.showSplash,
        styleType: self.sharedState.styleType,
        layoutType: self.sharedState.layoutType,
        themeType: self.sharedState.themeType,
        iconType: self.sharedState.iconAppType,
        hasPasscode: self.sharedState.hasPasscode,
        cameraStatus: self.sharedState.cameraStatus,
        optionTimeForAskPasscode: self.sharedState.optionTimeForAskPasscode,
        faceIdEnabled: self.sharedState.faceIdEnabled,
        language: self.sharedState.language,
        microphoneStatus: self.sharedState.microphoneStatus,
        route: self.sharedState.route
      )
    }
    set {
      self.sharedState.showSplash = newValue.showSplash
      self.sharedState.styleType = newValue.styleType
      self.sharedState.layoutType = newValue.layoutType
      self.sharedState.themeType = newValue.themeType
      self.sharedState.iconAppType = newValue.iconAppType
      self.sharedState.hasPasscode = newValue.hasPasscode
      self.sharedState.cameraStatus = newValue.cameraStatus
      self.sharedState.optionTimeForAskPasscode = newValue.optionTimeForAskPasscode
      self.sharedState.faceIdEnabled = newValue.faceIdEnabled
      self.sharedState.language = newValue.language
      self.sharedState.microphoneStatus = newValue.microphoneStatus
      self.sharedState.route = newValue.route
    }
  }
  
  public init(
    tabBars: [TabViewType],
    selectedTabBar: TabViewType = .entries,
    sharedState: SharedState
  ) {
    self.tabBars = tabBars
    self.selectedTabBar = selectedTabBar
    self.sharedState = sharedState
  }
}

public enum HomeAction: Equatable {
  case tabBarSelected(TabViewType)
  case starting
  case entries(EntriesAction)
  case search(Search.Action)
  case settings(Settings.Action)
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
    uuid: @escaping () -> UUID
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
  AnyReducer(
    Scope(state: \HomeState.settings, action: /HomeAction.settings) {
      Settings()
    }
  ),
  AnyReducer(
    Scope(state: \HomeState.search, action: /HomeAction.search) {
      Search()
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
          state: \.search,
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
