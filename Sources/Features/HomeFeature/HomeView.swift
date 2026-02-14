import SwiftUI
import ComposableArchitecture
import DesignSystem
import EntriesFeature
import SettingsFeature
import Models

public struct HomeView: View {
	@Bindable var store: StoreOf<HomeFeature>
	
	public init(
		store: StoreOf<HomeFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		TabView(
			selection: self.$store.selectedTabBar.sending(\.tabBarSelected)
    ) {
      EntriesView(
        store: store.scope(
          state: \.entries,
          action: \.entries
        )
      )
      .tabItem {
        Image(systemName: TabViewType.entries.icon)
        Text(TabViewType.entries.rawValue)
      }
      .tag(TabViewType.entries)
      
      SettingsView(
        store: store.scope(
          state: \.settings,
          action: \.settings
        )
      )
      .tabItem {
        Image(systemName: TabViewType.settings.icon)
        Text(TabViewType.settings.rawValue)
      }
      .tag(TabViewType.settings)
    }
		.accentColor(.chambray)
	}
}

#Preview {
	HomeView(
		store: Store(
			initialState: HomeFeature.State(),
			reducer: { HomeFeature() }
		)
	)
}
