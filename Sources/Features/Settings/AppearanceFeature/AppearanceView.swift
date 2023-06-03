import ComposableArchitecture
import Models
import Styles
import SwiftUI
import SwiftUIHelper
import Views

public struct AppearanceView: View {
	let store: StoreOf<AppearanceFeature>
	
	private struct ViewState: Equatable {
		let iconAppType: IconAppType
		let layoutType: LayoutType
		let styleType: StyleType
		let themeType: ThemeType
		
		init(
			state: AppearanceFeature.State
		) {
			self.iconAppType = state.iconAppType
			self.layoutType = state.layoutType
			self.styleType = state.styleType
			self.themeType = state.themeType
		}
	}
	public init(
		store: StoreOf<AppearanceFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: ViewState.init
		) { viewStore in
			Form {
				Section {
					NavigationLinkStore(
						self.store.scope(state: \.$destination, action: AppearanceFeature.Action.destination),
						state: /AppearanceFeature.Destination.State.layout,
						action: AppearanceFeature.Destination.Action.layout,
						onTap: { viewStore.send(.layoutButtonTapped) },
						destination: { store in
							let _ = print(store)
							LayoutView(store: store)
						},
						label: { LayoutRowView(title: viewStore.layoutType.rawValue.localized) }
					)
					NavigationLinkStore(
						self.store.scope(state: \.$destination, action: AppearanceFeature.Action.destination),
						state: /AppearanceFeature.Destination.State.style,
						action: AppearanceFeature.Destination.Action.style,
						onTap: { viewStore.send(.styleButtonTapped) },
						destination: StyleView.init(store:),
						label: { StyleRowView(title: viewStore.styleType.rawValue.localized) }
					)
					NavigationLinkStore(
						self.store.scope(state: \.$destination, action: AppearanceFeature.Action.destination),
						state: /AppearanceFeature.Destination.State.theme,
						action: AppearanceFeature.Destination.Action.theme,
						onTap: { viewStore.send(.themeButtonTapped) },
						destination: ThemeView.init(store:),
						label: {
							ThemeRowView(
								iconName: viewStore.themeType.icon,
								title: viewStore.themeType.rawValue.localized
							)
						}
					)
					NavigationLinkStore(
						self.store.scope(state: \.$destination, action: AppearanceFeature.Action.destination),
						state: /AppearanceFeature.Destination.State.iconApp,
						action: AppearanceFeature.Destination.Action.iconApp,
						onTap: { viewStore.send(.iconAppButtonTapped) },
						destination: IconAppView.init(store:),
						label: { IconAppRowView(title: viewStore.iconAppType.rawValue.localized) }
					)
				}
			}
		}
		.navigationBarTitle("Settings.Appearance".localized)
	}
}
