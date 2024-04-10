import SwiftUI
import ComposableArchitecture
import Models
import AddEntryFeature
import EntryDetailFeature

public struct EntriesView: View {
	@Perception.Bindable var store: StoreOf<EntriesFeature>
  
  public init(
    store: StoreOf<EntriesFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
		WithPerceptionTracking {
      NavigationStack {
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
									self.store.scope(state: \.entries, action: \.entries),
									id: \.id,
                  content: DayEntriesRowView.init
                )
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
					item: self.$store.scope(
						state: \.addEntryState,
						action: \.addEntryAction
					)
				) { store in
					AddEntryView(store: store)
				}
				#if os(tvOS)
				.navigationDestination(
					item: self.$store.scope(
						state: \.entryDetailState,
						action: \.entryDetailAction
					)
				) { store in
					EntryDetailView(store: store)
				}
				#endif
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .onAppear {
				self.store.send(.onAppear)
      }
    }
  }
}
