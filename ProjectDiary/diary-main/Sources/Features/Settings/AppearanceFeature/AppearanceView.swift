import ComposableArchitecture
import Models
import Styles
import SwiftUI
import SwiftUIHelper
import Views

public struct AppearanceView: View {
	private let store: StoreOf<AppearanceFeature>
	
	public init(
		store: StoreOf<AppearanceFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: \.appearanceSettings
		) { viewStore in
			Form {
				Section {
					NavigationLinkStore(
						self.store.scope(
							state: \.$destination,
							action: AppearanceFeature.Action.destination
						),
						state: /AppearanceFeature.Destination.State.layout,
						action: AppearanceFeature.Destination.Action.layout,
						onTap: { viewStore.send(.layoutButtonTapped) },
						destination: LayoutView.init,
						label: { LayoutRowView(title: viewStore.layoutType.rawValue.localized) }
					)
					NavigationLinkStore(
						self.store.scope(
							state: \.$destination,
							action: AppearanceFeature.Action.destination
						),
						state: /AppearanceFeature.Destination.State.style,
						action: AppearanceFeature.Destination.Action.style,
						onTap: { viewStore.send(.styleButtonTapped) },
						destination: StyleView.init,
						label: { StyleRowView(title: viewStore.styleType.rawValue.localized) }
					)
					NavigationLinkStore(
						self.store.scope(
							state: \.$destination,
							action: AppearanceFeature.Action.destination
						),
						state: /AppearanceFeature.Destination.State.theme,
						action: AppearanceFeature.Destination.Action.theme,
						onTap: { viewStore.send(.themeButtonTapped) },
						destination: ThemeView.init,
						label: {
							ThemeRowView(
								iconName: viewStore.themeType.icon,
								title: viewStore.themeType.rawValue.localized
							)
						}
					)
					NavigationLinkStore(
						self.store.scope(
							state: \.$destination,
							action: AppearanceFeature.Action.destination
						),
						state: /AppearanceFeature.Destination.State.iconApp,
						action: AppearanceFeature.Destination.Action.iconApp,
						onTap: { viewStore.send(.iconAppButtonTapped) },
						destination: IconAppView.init,
						label: { IconAppRowView(title: viewStore.iconAppType.rawValue.localized) }
					)
				}
			}
		}
		.navigationBarTitle("Settings.Appearance".localized)
	}
}

struct AppearanceView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			AppearanceView(
				store: Store(
					initialState: AppearanceFeature.State(
						appearanceSettings: .defaultValue
					),
					reducer: AppearanceFeature()
				)
			)
		}
	}
}
