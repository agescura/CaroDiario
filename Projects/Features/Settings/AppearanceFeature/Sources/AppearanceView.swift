import ComposableArchitecture
import SwiftUI
import Models
import Styles
import SwiftUIHelper
import Views

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
					self.store.send(.styleButtonTapped)
				} label: {
					StyleRowView(title: self.store.userSettings.appearance.styleType.rawValue.localized)
				}
				Button {
					self.store.send(.layoutButtonTapped)
				} label: {
					LayoutRowView(title: self.store.userSettings.appearance.layoutType.rawValue.localized)
				}
				Button {
					self.store.send(.themeButtonTapped)
				} label: {
					ThemeRowView(
						iconName: self.store.userSettings.appearance.themeType.icon,
						title:  self.store.userSettings.appearance.themeType.rawValue.localized
					)
				}
				Button {
					self.store.send(.iconAppButtonTapped)
				} label: {
					IconAppRowView(title: self.store.userSettings.appearance.iconAppType.rawValue.localized)
				}
			}
		}
		.navigationBarTitle("Settings.Appearance".localized)
	}
}

#Preview {
	AppearanceView(
		store: Store(
			initialState: AppearanceFeature.State(),
			reducer: { AppearanceFeature() }
		)
	)
}
