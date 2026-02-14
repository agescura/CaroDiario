import ComposableArchitecture
import DesignSystem
import Models
import SwiftUI

public struct AppearanceView: View {
  let store: StoreOf<AppearanceFeature>
  
  public init(
    store: StoreOf<AppearanceFeature>
  ) {
    self.store = store
  }
  
	public var body: some View {
		Form {
			Section {
				Button {
					store.send(.styleButtonTapped)
				} label: {
          AppearanceRowView(
            type: .style(
              title: store.userSettings.appearance.styleType.rawValue.localized
            )
          )
				}
				Button {
					store.send(.layoutButtonTapped)
				} label: {
          AppearanceRowView(
            type: .layout(
              title: store.userSettings.appearance.layoutType.rawValue.localized
            )
          )
				}
				Button {
					store.send(.themeButtonTapped)
				} label: {
          AppearanceRowView(
            type: .theme(
              iconName: store.userSettings.appearance.themeType.icon,
              title: store.userSettings.appearance.themeType.rawValue.localized
            )
          )
				}
				Button {
					store.send(.iconAppButtonTapped)
				} label: {
          AppearanceRowView(
            type: .icon(
              title: store.userSettings.appearance.iconAppType.rawValue.localized
            )
          )
				}
        .buttonStyle(.plain)
			}
		}
		.navigationBarTitle("Settings.Appearance".localized)
	}
}

#Preview {
  NavigationStack {
    AppearanceView(
      store: Store(
        initialState: AppearanceFeature.State()
      ) {
        AppearanceFeature()
      }
    )
  }
}
