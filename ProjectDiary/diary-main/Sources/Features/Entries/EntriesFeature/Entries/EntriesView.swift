import AddEntryFeature
import ComposableArchitecture
import EntryDetailFeature
import Models
import SwiftUI

public struct EntriesView: View {
	@Perception.Bindable var store: StoreOf<EntriesFeature>
  
  public init(
    store: StoreOf<EntriesFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
		WithPerceptionTracking {
			NavigationStack(path: self.$store.scope(state: \.path, action: \.path)) {
        ScrollView(.vertical) {
					if self.store.isLoading {
            ProgressView()
          } else if self.store.entries.isEmpty {
            VStack(spacing: 16) {
              Spacer()
              Image(.pencil)
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
                ForEach(
									Array(self.store.scope(state: \.entries, action: \.entries)),
									id: \.id
								) { store in
									DayEntriesRowView(store: store)
								}
              }
            }
          }
        }
        .navigationBarTitle("Entries.Diary".localized)
        .navigationBarItems(
          trailing:
            Button(action: {
							self.store.send(.addEntryButtonTapped)
            }) {
              Image(.plus)
                .foregroundColor(.chambray)
            }
        )
				.fullScreenCover(
					item: self.$store.scope(state: \.add, action: \.add)
				) { store in
					NavigationStack {
						AddEntryView(store: store)
							.toolbar {
								ToolbarItem(placement: .cancellationAction) {
									Text("AddEntry.Title".localized)
										.adaptiveFont(.latoBold, size: 16)
										.foregroundColor(.adaptiveBlack)
								}
								ToolbarItem(placement: .confirmationAction) {
									Button {
										self.store.send(.add(.dismiss))
									} label: {
										Image(.xmark)
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
				}
			}
      .navigationViewStyle(StackNavigationViewStyle())
      .task {
				await self.store.send(.task).finish()
      }
    }
  }
}

#Preview {
	EntriesView(
		store: Store(
			initialState: EntriesFeature.State(),
			reducer: { EntriesFeature() }
		)
	)
}
