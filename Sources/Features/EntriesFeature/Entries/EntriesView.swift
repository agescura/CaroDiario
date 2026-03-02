import ComposableArchitecture
import EntryDetailFeature
import Models
import SQLiteDataClient
import SwiftUI
import DesignSystem

@ViewAction(for: EntriesFeature.self)
public struct EntriesView: View {
	@Bindable public var store: StoreOf<EntriesFeature>
  
	public init(
		store: StoreOf<EntriesFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      ScrollView {
        if store.dayEntriesRows.isEmpty {
          ContentUnavailableView(
            "",
            systemImage: SystemImage.pencil.rawValue,
            description: Text("Entries.Empty".localized)
          )
        } else {
          DayEntriesView(
            dayEntriesRows: store.dayEntriesRows,
            layoutType: store.userSettings.appearance.layoutType,
            styleType: store.userSettings.appearance.styleType,
            contentAction: { entry in send(.entryButtonTapped(entry)) },
            labelAction: { dayEntry in send(.dayEntryButtonTapped(dayEntry.date)) }
          )
        }
      }
      .navigationBarTitle("Entries.Diary".localized)
      .navigationBarItems(
        trailing:
					Button(action: {
						send(.addEntryButtonTapped)
					}) {
            Image(systemName: .plus)
							.foregroundColor(.chambray)
					}
			)
			.fullScreenCover(
        item: $store.scope(
          state: \.destination?.add,
          action: \.destination.add
        )
			) { store in
				NavigationStack {
					EntryDetailView(store: store)
            .navigationTitle("AddEntry.Title".localized)
            .navigationBarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .cancellationAction) {
								Button {
                  send(.dismissButtonTapped)
								} label: {
                  Image(systemName: .xmark)
										.foregroundColor(.adaptiveBlack)
								}
							}
						}
				}
			}
		} destination: { store in
			switch store.case {
				case let .detail(store):
					EntryDetailView(store: store)
          .navigationTitle("AddEntry.Edit".localized)
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarBackButtonHidden()
          .toolbar {
            ToolbarItem {
              Button {
                send(.deleteButtonTapped)
              } label: {
                Image(systemName: .trash)
                  .foregroundColor(.adaptiveBlack)
              }
            }
            ToolbarItem(placement: .cancellationAction) {
              Button {
                send(.dismissButtonTapped)
              } label: {
                Image(systemName: .chevronLeft)
                  .foregroundColor(.adaptiveBlack)
              }
            }
          }
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
    .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
	}
}

#Preview {
  let _ = prepareDependencies {
    try! $0.bootstrapDatabase()
    try! $0.defaultDatabase.seed()
  }
	EntriesView(
		store: Store(
			initialState: EntriesFeature.State(),
      reducer: { EntriesFeature() }
		)
	)
}
