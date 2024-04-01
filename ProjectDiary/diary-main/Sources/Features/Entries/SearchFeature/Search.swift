import Foundation
import ComposableArchitecture
import AVAssetClient
import Models
import EntriesFeature
import FileClient
import UserDefaultsClient
import UIApplicationClient
import EntryDetailFeature

public struct Search: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var searchText: String = ""
    public var entries: IdentifiedArrayOf<DayEntriesRow.State>
    
    public var attachmentSearchState: AttachmentSearch.State?
    public var navigateAttachmentSearch = false
    
    public var entryDetailState: EntryDetail.State?
    public var navigateEntryDetail = false
    public var entryDetailSelected: Entry?
    
    public var entriesCount: Int {
      entries.map(\.dayEntries.entries.count).reduce(0, +)
    }
    
    public init(
      searchText: String = "",
      entries: IdentifiedArrayOf<DayEntriesRow.State> = []
    ) {
      self.searchText = searchText
      self.entries = entries
    }
  }

  public enum Action: Equatable {
    case searching(newText: String)
    case searchResponse([[Entry]])
    case entries(id: UUID, action: DayEntriesRow.Action)
    case remove(Entry)
    
    case attachmentSearchAction(AttachmentSearch.Action)
    case navigateAttachmentSearch(Bool)
    case navigateImageSearch
    case navigateVideoSearch
    case navigateAudioSearch
    case navigateSearch(AttachmentSearchType, [[Entry]])
    
    case entryDetailAction(EntryDetail.Action)
    case navigateEntryDetail(Bool)
  }
  
  @Dependency(\.userDefaultsClient) private var userDefaultsClient
  @Dependency(\.uuid) private var uuid
  @Dependency(\.mainQueue) private var mainQueue
  @Dependency(\.fileClient) private var fileClient
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .forEach(\.entries, action: /Action.entries) {
        DayEntriesRow()
      }
      .ifLet(\.attachmentSearchState, action: /Action.attachmentSearchAction) {
        AttachmentSearch()
      }
      .ifLet(\.entryDetailState, action: /Action.entryDetailAction) {
        EntryDetail()
      }

  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action> {
    switch action {
    case let .searching(newText: newText):
      state.searchText = newText
      return .none
      
    case let .searchResponse(response):
      var dayResult: IdentifiedArrayOf<DayEntriesRow.State> = []
      
      for entries in response {
        let day = DayEntriesRow.State(dayEntry: .init(
          entry: .init(uniqueElements: entries), style: self.userDefaultsClient.styleType, layout: self.userDefaultsClient.layoutType), id: self.uuid())
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
      return .none
      
    case .navigateVideoSearch:
      return .none
      
    case .navigateAudioSearch:
      return .none
      
    case let .navigateSearch(type, response):
      var dayResult: IdentifiedArrayOf<DayEntriesRow.State> = []
      
      for entries in response {
        let day = DayEntriesRow.State(dayEntry: .init(
          entry: .init(uniqueElements: entries), style: self.userDefaultsClient.styleType, layout: self.userDefaultsClient.layoutType), id: self.uuid())
        dayResult.append(day)
      }
      
      state.attachmentSearchState = .init(type: type, entries: dayResult)
      state.navigateAttachmentSearch = true
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
        .run { send in
          _ = await self.fileClient.removeAttachments(entry.attachments.urls)
          await send(.remove(entry))
        },
        Effect(value: .navigateEntryDetail(false))
      )
      
    case .entryDetailAction:
      return .none
    }
  }
}
