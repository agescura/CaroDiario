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

@Reducer
public struct HomeFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		public var entries: EntriesFeature.State
		public var search: Search.State
		public var selectedTabBar: TabViewType
		public var settings: SettingsFeature.State
		public var tabBars: [TabViewType]
		
		public init(
			entries: EntriesFeature.State = EntriesFeature.State(),
			search: Search.State = Search.State(),
			selectedTabBar: TabViewType = .entries,
			settings: SettingsFeature.State = SettingsFeature.State(),
			tabBars: [TabViewType]
		) {
			self.entries = entries
			self.search = search
			self.selectedTabBar = selectedTabBar
			self.settings = settings
			self.tabBars = tabBars
		}
	}
	
	public enum Action: Equatable {
		case entries(EntriesFeature.Action)
		case search(Search.Action)
		case settings(SettingsFeature.Action)
		case tabBarSelected(TabViewType)
		case task
	}
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.entries, action: \.entries) {
			EntriesFeature()
		}
		Scope(state: \.search, action: \.search) {
			Search()
		}
		Scope(state: \.settings, action: \.settings) {
			SettingsFeature()
		}
		Reduce { state, action in
			switch action {
				case let .tabBarSelected(tab):
					state.selectedTabBar = tab
					return .none
					
				case .task, .entries, .settings, .search:
					return .none
			}
		}
	}
}
