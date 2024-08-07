import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import CoreDataClient
import FileClient
import EntriesFeature
import SettingsFeature
import AddEntryFeature
import Models
import LocalAuthenticationClient
import UIApplicationClient
import AVCaptureDeviceClient
import SearchFeature
import AVAudioSessionClient
import AVAudioPlayerClient
import AVAudioRecorderClient
import StoreKitClient
import PDFKitClient
import AVAssetClient
import Styles
import EntryDetailFeature

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
			ForEach(self.store.tabBars, id: \.self) { type in
				type.view(for: self.store)
					.tabItem {
						VStack {
							Image(systemName: type.icon)
							Text(type.rawValue)
						}
					}
					.tag(type)
			}
		}
		.accentColor(.chambray)
	}
}

extension TabViewType {
	@ViewBuilder
	func view(for store: StoreOf<HomeFeature>) -> some View {
		switch self {
			case .entries:
				EntriesView(store: store.scope(state: \.entries, action: \.entries))
			case .search:
				SearchView(store: store.scope(state: \.search, action: \.search))
			case .settings:
				SettingsView(store: store.scope(state: \.settings, action: \.settings))
		}
	}
}

#Preview {
	HomeView(
		store: Store(
			initialState: HomeFeature.State(
				tabBars: [.entries, .search, .settings]
			),
			reducer: { HomeFeature() }
		)
	)
}
