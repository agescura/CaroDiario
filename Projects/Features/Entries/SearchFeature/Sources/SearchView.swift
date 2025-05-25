import ComposableArchitecture
import SwiftUI
import EntriesFeature
import EntryDetailFeature

public struct SearchView: View {
  @Bindable var store: StoreOf<Search>
  @ObservedObject var searchBar = SearchBar()
  
  public init(
    store: StoreOf<Search>
  ) {
    self.store = store
  }
  
  public var body: some View {
		NavigationStack {
			VStack {
				if store.searchText.isEmpty {
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
							store.send(.navigateImageSearch)
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
							store.send(.navigateVideoSearch)
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
							store.send(.navigateAudioSearch)
						}
						
						Divider()
						
						Spacer()
					}
					.padding()
				} else if store.entries.isEmpty {
					Text("Search.Empty".localized)
						.foregroundColor(.chambray)
						.adaptiveFont(.latoRegular, size: 10)
				}
				
				if !store.entries.isEmpty {
					ScrollView(.vertical) {
						VStack(alignment: .leading, spacing: 16) {
							Text("\("Search.Results".localized)\(store.entriesCount)")
								.foregroundColor(.chambray)
								.adaptiveFont(.latoRegular, size: 10)
								.padding(.leading)
							
							LazyVStack(alignment: .leading, spacing: 8) {
								ForEach(
									store.scope(
										state: \.entries,
										action: \.entries
									),
									id: \.state.id,
								) { store in
									DayEntriesRowView(store: store)
								}
							}
						}
						.padding(.top, 16)
					}
				}
			}
			.navigationBarTitle("Search.Title".localized)
			.add(searchBar) {
				store.send(.searching(newText: $0))
			}
			.navigationDestination(
				item: $store.scope(
					state: \.entryDetailState,
					action: \.entryDetailAction
				)
			) { store in
				EntryDetailView(store: store)
			}
			.navigationDestination(
				item: $store.scope(
					state: \.attachmentSearchState,
					action: \.attachmentSearchAction
				)
			) { store in
				AttachmentSearchView(store: store)
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
  }
}
