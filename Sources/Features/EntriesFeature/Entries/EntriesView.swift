import ComposableArchitecture
import EntryDetailFeature
import Models
import SQLiteDataClient
import SwiftUI
import DesignSystem

public struct EntriesView: View {
	@Bindable var store: StoreOf<EntriesFeature>
  
	public init(
		store: StoreOf<EntriesFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
    NavigationStack(path: self.$store.scope(state: \.path, action: \.path)) {
      ScrollView {
        if self.store.dayEntriesRows.isEmpty {
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
            contentAction: { entry in store.send(.entryButtonTapped(entry)) },
            labelAction: { dayEntry in store.send(.dayEntryButtonTapped(dayEntry.date)) }
          )
        }
      }
      .navigationBarTitle("Entries.Diary".localized)
      .navigationBarItems(
        trailing:
					Button(action: {
						self.store.send(.addEntryButtonTapped)
					}) {
            Image(systemName: .plus)
							.foregroundColor(.chambray)
					}
			)
			.fullScreenCover(
				item: self.$store.scope(state: \.add, action: \.add)
			) { store in
				NavigationStack {
					EntryDetailView(store: store)
            .navigationTitle("AddEntry.Title".localized)
            .navigationBarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .cancellationAction) {
								Button {
                  self.store.send(.dismissButtonTapped)
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
            ToolbarItem(placement: .cancellationAction) {
              Button {
                self.store.send(.dismissButtonTapped)
              } label: {
                Image(systemName: .chevronLeft)
                  .foregroundColor(.adaptiveBlack)
              }
            }
          }
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.task {
			await self.store.send(.task).finish()
		}
    .alert(
      store: store.scope(
        state: \.$alert,
        action: \.alert
      )
    )
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
      reducer: { EntriesFeature()._printChanges() }
		)
	)
}
