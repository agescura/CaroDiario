//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 21/11/22.
//

import Foundation
import ComposableArchitecture
import BackgroundQueue
import UIApplicationClient
import UserDefaultsClient
import FileClient
import Models
import AddEntryFeature
import EntryDetailFeature
import CoreDataClient

public struct Entries: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
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

  public enum Action: Equatable {
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
  
  @Dependency(\.mainQueue) private var mainQueue
  @Dependency(\.uuid) private var uuid
  @Dependency(\.mainRunLoop.now.date) private var now
  @Dependency(\.applicationClient) private var applicationClient
  @Dependency(\.backgroundQueue) private var backgroundQueue
  @Dependency(\.userDefaultsClient) private var userDefaultsClient
  @Dependency(\.fileClient) private var fileClient
  private struct CoreDataId: Hashable {}
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .forEach(\.entries, action: /Action.entries) {
        DayEntriesRow()
      }
      .ifLet(\.addEntryState, action: /Action.addEntryAction) {
        AddEntry()
      }
      .ifLet(\.entryDetailState, action: /Action.entryDetailAction) {
        EntryDetail()
      }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action, Never> {
    switch action {
      
    case .onAppear:
      return .none
      
    case let .coreDataClientAction(.entries(response)):
      return Effect(value: .fetchEntriesResponse(response))
        .receive(on: self.mainQueue)
        .eraseToEffect()
      
    case let .fetchEntriesResponse(response):
      var dayResult: IdentifiedArrayOf<DayEntriesRow.State> = []
      
      for entries in response {
        let day = DayEntriesRow.State(
          dayEntry: .init(entry: .init(uniqueElements: entries),
                          style: self.userDefaultsClient.styleType,
                          layout: self.userDefaultsClient.layoutType),
          id: self.uuid())
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
        id: self.uuid(),
        date: self.now,
        startDay: self.now,
        text: .init(
          id: self.uuid(),
          message: "",
          lastUpdated: self.now
        )
      )
      state.addEntryState = .init(type: .add, entry: newEntry)
      return Effect(value: .addEntryAction(.createDraftEntry))
      
    case .presentAddEntry(false):
      state.presentAddEntry = false
      return Effect(value: .presentAddEntryCompleted)
        .delay(for: 0.3, scheduler: self.mainQueue)
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
        self.fileClient.removeAttachments(entry.attachments.urls, self.backgroundQueue)
          .receive(on: self.mainQueue)
          .eraseToEffect()
          .map({ Entries.Action.remove(entry) }),
        Effect(value: .navigateEntryDetail(false))
      )
      
    case .entryDetailAction:
      return .none
    }
  }
}
