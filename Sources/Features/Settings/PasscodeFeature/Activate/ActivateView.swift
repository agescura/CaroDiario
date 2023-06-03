import SwiftUI
import ComposableArchitecture
import Views
import SwiftUIHelper
import Localizables

public struct ActivateView: View {
  let store: StoreOf<ActivateFeature>
  
  public init(
    store: StoreOf<ActivateFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(
		self.store.stateless
	 ) { viewStore in
      VStack(spacing: 16) {
        Text("Passcode.Title".localized)
          .font(.title)
        Text("Passcode.Activate.Message".localized)
          .font(.caption)
        Spacer()
        
        PrimaryButtonView(
          label: { Text("Passcode.Activate.Title".localized) }
        ) {
          viewStore.send(.navigateToInsert)
        }
        
			NavigationLinkStore(
				self.store.scope(
					state: \.$insert,
					action: ActivateFeature.Action.insert
				),
				destination: InsertView.init(store:),
				label: EmptyView.init
			)
      }
      .padding(.horizontal, 16)
    }
  }
}
