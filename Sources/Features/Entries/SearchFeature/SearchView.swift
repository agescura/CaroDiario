import ComposableArchitecture
import SwiftUI
import EntriesFeature
import EntryDetailFeature

public struct SearchView: View {
  let store: StoreOf<Search>
  @ObservedObject var searchBar = SearchBar()
  
  public init(
    store: StoreOf<Search>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      NavigationView {
        VStack {
          if viewStore.searchText.isEmpty {
            VStack(spacing: 16) {
              
              HStack(spacing: 16) {
                Text(AttachmentSearchType.images.title)
                  .foregroundColor(.adaptiveGray)
                  .adaptiveFont(.latoRegular, size: 10)
                Spacer()
                Image(.chevronRight)
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
                Image(.chevronRight)
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
                Image(.chevronRight)
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
        .navigationBarTitle("Search.Title".localized)
        .add(searchBar) {
          viewStore.send(.searching(newText: $0))
        }
//        .navigationDestination(
//          isPresented: viewStore.binding(
//            get: \.navigateEntryDetail,
//            send: Search.Action.navigateEntryDetail
//          ),
//          destination: {
//            IfLetStore(
//              store.scope(
//                state: \.entryDetailState,
//                action: Search.Action.entryDetailAction
//              ),
//              then: EntryDetailView.init(store:)
//            )
//          }
//        )
//        .navigationDestination(
//          isPresented: viewStore.binding(
//            get: \.navigateAttachmentSearch,
//            send: Search.Action.navigateAttachmentSearch
//          ),
//          destination: {
//            IfLetStore(
//              store.scope(
//                state: \.attachmentSearchState,
//                action: Search.Action.attachmentSearchAction
//              ),
//              then: AttachmentSearchView.init(store:)
//            )
//          }
//        )
      }
      .navigationViewStyle(StackNavigationViewStyle())
    }
  }
}
