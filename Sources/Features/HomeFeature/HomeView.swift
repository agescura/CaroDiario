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
import FeedbackGeneratorClient
import SearchFeature
import AVAudioSessionClient
import AVAudioPlayerClient
import AVAudioRecorderClient
import StoreKitClient
import PDFKitClient
import AVAssetClient
import Styles
import EntryDetailFeature
import TCAHelpers
import SwiftUIHelper

public struct HomeFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var tabBars: [TabViewType]
		public var selectedTabBar: TabViewType
		public var userSettings: UserSettings
		
		//		public var entries: Entries.State {
		//			get {
		//				.init(
		//					isLoading: self.sharedState.isLoading,
		//					entries: self.sharedState.entries,
		//					addEntryState: self.sharedState.addEntryState,
		//					presentAddEntry: self.sharedState.presentAddEntry,
		//					entryDetailState: self.sharedState.entryDetailState,
		//					navigateEntryDetail: self.sharedState.navigateEntryDetail,
		//					entryDetailSelected: self.sharedState.entryDetailSelected
		//				)
		//			}
		//			set {
		//				self.sharedState.isLoading = newValue.isLoading
		//				self.sharedState.entries = newValue.entries
		//				self.sharedState.addEntryState = newValue.addEntryState
		//				self.sharedState.presentAddEntry = newValue.presentAddEntry
		//				self.sharedState.entryDetailState = newValue.entryDetailState
		//				self.sharedState.entryDetailSelected = newValue.entryDetailSelected
		//				self.sharedState.navigateEntryDetail = newValue.navigateEntryDetail
		//
		//			}
		//		}
		//		public var search: Search.State {
		//			get { self.sharedState.search }
		//			set { self.sharedState.search = newValue }
		//		}
		
		public var settings: SettingsFeature.State
		
		public init(
			tabBars: [TabViewType],
			selectedTabBar: TabViewType = .entries,
			userSettings: UserSettings
		) {
			self.tabBars = tabBars
			self.selectedTabBar = selectedTabBar
			self.userSettings = userSettings
			self.settings = SettingsFeature.State(userSettings: userSettings)
		}
	}
	
	public enum Action: Equatable {
		case tabBarSelected(TabViewType)
		case starting
		case entries(Entries.Action)
		case search(Search.Action)
		case settings(SettingsFeature.Action)
	}
	
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	
	public var body: some ReducerProtocolOf<Self> {
		//		Scope(state: \.entries, action: /Action.entries) {
		//			Entries()
		//		}
		Scope(state: \.settings, action: /Action.settings) {
			SettingsFeature()
		}
		//		Scope(state: \.search, action: /Action.search) {
		//			Search()
		//		}
		Reduce { state, action in
			switch action {
				case let .tabBarSelected(tab):
					state.selectedTabBar = tab
					return .none
					
				case .starting, .entries, .settings, .search:
					return .none
			}
		}
	}
}

public struct HomeView: View {
	let store: StoreOf<HomeFeature>
	
	public init(
		store: StoreOf<HomeFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(self.store) { viewStore in
			TabView(
				selection: viewStore.binding(
					get: { $0.selectedTabBar },
					send: HomeFeature.Action.tabBarSelected)
			) {
				ForEach(viewStore.tabBars, id: \.self) { type in
					type.view(for: self.store)
						.tabItem {
							VStack {
								Image(systemName: type.icon)
								Text(type.rawValue)
							}
						}
				}
			}
			.accentColor(.chambray)
		}
		.accentColor(.chambray)
	}
}

extension TabViewType {
	
	@ViewBuilder
	func view(for store: StoreOf<HomeFeature>) -> some View {
		switch self {
				
			case .entries:
				Text("Entries")
				//				EntriesView(
				//					store: store.scope(
				//						state: \.entries,
				//						action: Home.Action.entries
				//					)
				//				)
				
			case .search:
				Text("Search")
				//				SearchView(
				//					store: store.scope(
				//						state: \.search,
				//						action: Home.Action.search
				//					)
				//				)
				
			case .settings:
				NavigationSwitched {
					SettingsView(
						store: store.scope(
							state: \.settings,
							action: HomeFeature.Action.settings
						)
					)
					.navigationTitle("Settings.Title".localized)
				}
				.navigationViewStyle(StackNavigationViewStyle())
		}
	}
}
