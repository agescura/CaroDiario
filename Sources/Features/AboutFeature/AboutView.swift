import ComposableArchitecture
import DesignSystem
import Localizables
import SwiftUI

public struct AboutView: View {
	@Bindable var store: StoreOf<AboutFeature>
	
	public init(
		store: StoreOf<AboutFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
    Form {
      Section {
        LabeledContent("Settings.Version".localized) {
          Text("1.7")
        }
        .labeledContentStyle(.default)
      }
      Section {
        LabeledContent("Settings.ReportBug".localized) {
          Image(systemName: .chevronRight)
        }
        .labeledContentStyle(.default)
      }
      .contentShape(Rectangle())
      .onTapGesture {
        store.send(.confirmationDialogButtonTapped)
      }
    }
		.confirmationDialog($store.scope(state: \.dialog, action: \.dialog))
		.navigationBarTitle("Settings.About".localized)
	}
}

#Preview {
  registerFonts()
  return NavigationView {
    AboutView(
      store: Store(
        initialState: AboutFeature.State()
      ) {
        AboutFeature()
      }
    )
  }
}
