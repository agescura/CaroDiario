import SwiftUI
import ComposableArchitecture
import Models
import AddEntryFeature
import EntryDetailFeature
import BackgroundQueue

public struct EntriesView: View {
	private let store: StoreOf<Entries>
	
	public init(
		store: StoreOf<Entries>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			
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
										action: Entries.Action.entries(id:action:)),
									content: DayEntriesRowView.init(store:)
								)
							}
							
							NavigationLink(
								"",
								destination:
									IfLetStore(
										store.scope(
											state: \.entryDetailState,
											action: Entries.Action.entryDetailAction
										),
										then: EntryDetailView.init(store:)
									),
								isActive: viewStore.binding(
									get: \.navigateEntryDetail,
									send: Entries.Action.navigateEntryDetail)
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
						action: Entries.Action.destination
					),
					state: /Entries.Destination.State.addEntry,
					action: Entries.Destination.Action.addEntry
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
