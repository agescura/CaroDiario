import SwiftUI
import ComposableArchitecture
import Models
import AddEntryFeature
import EntryDetailFeature

public struct EntriesView: View {
  let store: StoreOf<Entries>
  
  public init(
    store: StoreOf<Entries>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      NavigationStack {
        ScrollView(.vertical) {
          if viewStore.isLoading {
            ProgressView()
          } else if viewStore.entries.isEmpty {
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
                ForEachStore(
                  store.scope(
                    state: \.entries,
                    action: Entries.Action.entries(id:action:)),
                  content: DayEntriesRowView.init(store:)
                )
              }
            }
          }
        }
        .navigationBarTitle("Entries.Diary".localized)
        .navigationBarItems(
          trailing:
            Button(action: {
              viewStore.send(.presentAddEntry(true))
            }) {
              Image(.plus)
                .foregroundColor(.chambray)
            }
        )
        .fullScreenCover(
          isPresented: viewStore.binding(
            get: { $0.presentAddEntry },
            send: Entries.Action.presentAddEntry
          )
        ) {
          IfLetStore(
            store.scope(
              state: { $0.addEntryState },
              action: Entries.Action.addEntryAction),
            then: AddEntryView.init(store:)
          )
        }
        .navigationDestination(
          isPresented: viewStore.binding(
            get: \.navigateEntryDetail,
            send: Entries.Action.navigateEntryDetail
          ),
          destination: {
            IfLetStore(
              store.scope(
                state: \.entryDetailState,
                action: Entries.Action.entryDetailAction
              ),
              then: EntryDetailView.init(store:)
            )
          }
        )
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}
