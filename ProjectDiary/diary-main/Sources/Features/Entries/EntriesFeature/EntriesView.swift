//
//  ContentView.swift
//  ProjectDiary
//
//  Created by Albert Gil Escura on 24/6/21.
//

import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import Models
import CoreDataClient
import FileClient
import AddEntryFeature
import AVCaptureDeviceClient
import UIApplicationClient
import AVAudioRecorderClient
import AVAudioSessionClient
import AVAudioPlayerClient
import EntryDetailFeature
import AVAssetClient

public struct EntriesState: Equatable {
  public var isLoading: Bool
  public var entries: IdentifiedArrayOf<DayEntriesRow.State>
  
  public var addEntryState: AddEntry.State?
  public var presentAddEntry = false
  
  public var entryDetailState: EntryDetail.State?
  public var navigateEntryDetail = false
  public var entryDetailSelected: Entry?
  
  public init(
    isLoading: Bool = true,
    entries: IdentifiedArrayOf<DayEntriesRow.State> = [],
    addEntryState: AddEntry.State? = nil,
    presentAddEntry: Bool = false,
    entryDetailState: EntryDetail.State? = nil,
    navigateEntryDetail: Bool = false,
    entryDetailSelected: Entry? = nil
  ) {
    self.isLoading = isLoading
    self.entries = entries
    self.addEntryState = addEntryState
    self.presentAddEntry = presentAddEntry
    self.entryDetailState = entryDetailState
    self.navigateEntryDetail = navigateEntryDetail
    self.entryDetailSelected = entryDetailSelected
  }
}

public enum EntriesAction: Equatable {
  case onAppear
  case coreDataClientAction(CoreDataClient.Action)
  case fetchEntriesResponse([[Entry]])
  
  case addEntryAction(AddEntry.Action)
  case presentAddEntry(Bool)
  case presentAddEntryCompleted
  
  case entries(id: UUID, action: DayEntriesRow.Action)
  case remove(Entry)
  
  case entryDetailAction(EntryDetail.Action)
  case navigateEntryDetail(Bool)
}

public struct EntriesEnvironment {
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
  public let date: () -> Date
  public let uuid: () -> UUID
  
  public init(
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
    date: @escaping () -> Date,
    uuid: @escaping () -> UUID
  ) {
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
    self.date = date
    self.uuid = uuid
  }
}

public let entriesReducer: Reducer<
  EntriesState,
  EntriesAction,
  EntriesEnvironment
> = .combine(
  AnyReducer(
    EmptyReducer()
      .forEach(\.entries, action: /EntriesAction.entries) {
        DayEntriesRow()
      }
  ),
  AnyReducer(
    EmptyReducer()
      .ifLet(\.addEntryState, action: /EntriesAction.addEntryAction) {
        AddEntry()
      }
      .ifLet(\.entryDetailState, action: /EntriesAction.entryDetailAction) {
        EntryDetail()
      }
  ),
  
    .init { state, action, environment in
      struct CoreDataId: Hashable {}
      
      switch action {
        
      case .onAppear:
        return .none
        
      case let .coreDataClientAction(.entries(response)):
        return Effect(value: .fetchEntriesResponse(response))
          .receive(on: environment.mainQueue)
          .eraseToEffect()
        
      case let .fetchEntriesResponse(response):
        var dayResult: IdentifiedArrayOf<DayEntriesRow.State> = []
        
        for entries in response {
          let day = DayEntriesRow.State(
            dayEntry: .init(entry: .init(uniqueElements: entries),
                            style: environment.userDefaultsClient.styleType,
                            layout: environment.userDefaultsClient.layoutType),
            id: environment.uuid())
          dayResult.append(day)
        }
        
        state.entries = dayResult
        state.isLoading = false
        return .none
        
      case .addEntryAction(.addButtonTapped):
        state.presentAddEntry = false
        return .none
        
      case .addEntryAction(.finishAddEntry):
        state.presentAddEntry = false
        return .none
        
      case .addEntryAction:
        return .none
        
      case .presentAddEntry(true):
        state.presentAddEntry = true
        let newEntry = Entry(
          id: environment.uuid(),
          date: environment.date(),
          startDay: environment.date(),
          text: .init(
            id: environment.uuid(),
            message: "",
            lastUpdated: environment.date()
          )
        )
        state.addEntryState = .init(type: .add, entry: newEntry)
        return Effect(value: .addEntryAction(.createDraftEntry))
        
      case .presentAddEntry(false):
        state.presentAddEntry = false
        return Effect(value: .presentAddEntryCompleted)
          .delay(for: 0.3, scheduler: environment.mainQueue)
          .eraseToEffect()
        
      case .presentAddEntryCompleted:
        state.addEntryState = nil
        return .none
        
      case let .entries(id: _, action: .dayEntry(.navigateDetail(entry))):
        state.entryDetailSelected = entry
        return Effect(value: .navigateEntryDetail(true))
        
      case .entries:
        return .none
        
      case .remove:
        return .none
        
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
            .map({ EntriesAction.remove(entry) }),
          Effect(value: .navigateEntryDetail(false))
        )
        
      case .entryDetailAction:
        return .none
      }
    }
)

public struct EntriesView: View {
  let store: Store<EntriesState, EntriesAction>
  
  public init(
    store: Store<EntriesState, EntriesAction>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store) { viewStore in
      
      NavigationView {
        ScrollView(.vertical) {
          if viewStore.isLoading {
            ProgressView()
          } else if viewStore.entries.isEmpty {
            VStack(spacing: 16) {
              Spacer()
              Image(systemName: "pencil")
                .resizable()
                .foregroundColor(.adaptiveBlack)
                .frame(width: 24, height: 24)
              Text("Entries.Empty".localized)
                .multilineTextAlignment(.center)
                .foregroundColor(.adaptiveBlack)
                .adaptiveFont(.latoRegular, size: 12)
              Spacer()
            }
            .padding()
          } else {
            ZStack {
              LazyVStack(alignment: .leading, spacing: 8) {
                ForEachStore(
                  store.scope(
                    state: \.entries,
                    action: EntriesAction.entries(id:action:)),
                  content: DayEntriesRowView.init(store:)
                )
              }
              
              NavigationLink(
                "",
                destination:
                  IfLetStore(
                    store.scope(
                      state: \.entryDetailState,
                      action: EntriesAction.entryDetailAction
                    ),
                    then: EntryDetailView.init(store:)
                  ),
                isActive: viewStore.binding(
                  get: \.navigateEntryDetail,
                  send: EntriesAction.navigateEntryDetail)
              )
            }
          }
        }
        .navigationBarTitle("Entries.Diary".localized)
        .navigationBarItems(
          trailing:
            Button(action: {
              viewStore.send(.presentAddEntry(true))
            }) {
              Image(systemName: "plus")
                .foregroundColor(.chambray)
            }
        )
        .fullScreenCover(
          isPresented: viewStore.binding(
            get: { $0.presentAddEntry },
            send: EntriesAction.presentAddEntry
          )
        ) {
          IfLetStore(
            store.scope(
              state: { $0.addEntryState },
              action: EntriesAction.addEntryAction),
            then: AddEntryView.init(store:)
          )
        }
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}
