import SwiftUI
import ComposableArchitecture
import Models
import AddEntryFeature
import EntryDetailFeature

public struct EntriesView: View {
	private let store: StoreOf<EntriesFeature>
	
	public init(
		store: StoreOf<EntriesFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: { $0 }
		) { viewStore in
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
										action: EntriesFeature.Action.entries(id:action:)),
									content: DayEntriesRowView.init(store:)
								)
							}
							
							NavigationLink(
								"",
								destination:
									IfLetStore(
										store.scope(
											state: \.entryDetailState,
											action: EntriesFeature.Action.entryDetailAction
										),
										then: EntryDetailView.init(store:)
									),
								isActive: viewStore.binding(
									get: \.navigateEntryDetail,
									send: EntriesFeature.Action.navigateEntryDetail)
							)
						}
					}
				}
				.navigationBarTitle("Entries.Diary".localized)
				.navigationBarItems(
					trailing:
						Button(action: {
							viewStore.send(.addEntryButtonTapped)
						}) {
							Image(systemName: "plus")
								.foregroundColor(.chambray)
						}
				)
				.fullScreenCover(
					store: self.store.scope(
						state: \.$destination,
						action: EntriesFeature.Action.destination
					),
					state: /EntriesFeature.Destination.State.addEntry,
					action: EntriesFeature.Destination.Action.addEntry
				) { store in
					NavigationView {
						AddEntryView(store: store)
							.navigationTitle("AddEntry.Title".localized)
							.toolbar {
								ToolbarItem(placement: .primaryAction) {
									Button {
										viewStore.send(.destination(.presented(.addEntry(.dismissAlertButtonTapped))))
									} label: {
										Image(systemName: "xmark")
											.foregroundColor(.adaptiveBlack)
									}
								}
							}
					}
				}
			}
			.navigationViewStyle(StackNavigationViewStyle())
			.onAppear {
				viewStore.send(.onAppear)
			}
		}
	}
}
