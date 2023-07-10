import ComposableArchitecture
import EntriesFeature
import EntryDetailFeature
import SwiftUI
import TCAHelpers

public struct SearchView: View {
	private let store: StoreOf<SearchFeature>
	@ObservedObject private var searchBar = SearchBar()
	
	public init(
		store: StoreOf<SearchFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: { $0 }
		) { viewStore in
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
												action: SearchFeature.Action.entries(id:action:)),
											content: DayEntriesRowView.init(store:)
										)
									}
								}
								.padding(.top, 16)
							}
						}
					}
					
					NavigationLinkStore(
						self.store.scope(state: \.$destination, action: SearchFeature.Action.destination),
						state: /SearchFeature.Destination.State.entryDetail,
						action: SearchFeature.Destination.Action.entryDetail
					) { store in
						EntryDetailView(store: store)
					}
					
					NavigationLinkStore(
						self.store.scope(state: \.$destination, action: SearchFeature.Action.destination),
						state: /SearchFeature.Destination.State.attachmentSearch,
						action: SearchFeature.Destination.Action.attachmentSearch
					) { store in
						AttachmentSearchView(store: store)
					}
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
