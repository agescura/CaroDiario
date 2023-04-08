import SwiftUI
import ComposableArchitecture
import Views
import SwiftUIHelper
import Localizables

public struct ActivateView: View {
  let store: StoreOf<Activate>
  
  public init(
    store: StoreOf<Activate>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack(spacing: 16) {
        Text("Passcode.Title".localized)
          .font(.title)
        Text("Passcode.Activate.Message".localized)
          .font(.caption)
        Spacer()
        
        PrimaryButtonView(
          label: { Text("Passcode.Activate.Title".localized) }
        ) {
          viewStore.send(.navigateInsert(true))
        }
        
        NavigationLink(
          route: viewStore.route,
          case: /Activate.State.Route.insert,
          onNavigate: { viewStore.send(.navigateInsert($0)) },
          destination: { insertState in
            InsertView(
              store: self.store.scope(
                state: { _ in insertState },
                action: Activate.Action.insert
              )
            )
          },
          label: EmptyView.init
        )
      }
      .padding(.horizontal, 16)
    }
  }
}
