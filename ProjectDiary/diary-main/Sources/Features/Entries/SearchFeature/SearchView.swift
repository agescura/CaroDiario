import ComposableArchitecture
import SwiftUI
import Models
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
  @Dependency(\.backgroundQueue) private var backgroundQueue
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
  ) -> Effect<Action, Never> {
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
        self.fileClient.removeAttachments(entry.attachments.urls, self.backgroundQueue)
          .receive(on: self.mainQueue)
          .eraseToEffect()
          .map({ Search.Action.remove(entry) }),
        Effect(value: .navigateEntryDetail(false))
      )
      
    case .entryDetailAction:
      return .none
    }
  }
}

public struct SearchView: View {
  private let store: StoreOf<Search>
  @ObservedObject private var searchBar = SearchBar()
  
  public init(
    store: StoreOf<Search>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
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
                        action: Search.Action.entries(id:action:)),
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
                  action: Search.Action.entryDetailAction
                ),
                then: EntryDetailView.init(store:)
              ),
            isActive: viewStore.binding(
              get: \.navigateEntryDetail,
              send: Search.Action.navigateEntryDetail)
          )
          
          NavigationLink(
            "",
            destination:
              IfLetStore(
                store.scope(
                  state: \.attachmentSearchState,
                  action: Search.Action.attachmentSearchAction
                ),
                then: AttachmentSearchView.init(store:)
              ),
            isActive: viewStore.binding(
              get: \.navigateAttachmentSearch,
              send: Search.Action.navigateAttachmentSearch)
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
