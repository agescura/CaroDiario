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

//public struct SharedState: Equatable {
//	public var isLoading: Bool = true
//	public var entries: IdentifiedArrayOf<DayEntriesRow.State> = []
//	public var addEntryState: AddEntryFeature.State?
//	public var presentAddEntry = false
//	public var entryDetailState: EntryDetailFeature.State?
//	public var navigateEntryDetail = false
//	public var entryDetailSelected: Entry?
//	
//	public var search: Search.State = Search.State()
//	
//	public var showSplash: Bool
//	public var styleType: StyleType
//	public var layoutType: LayoutType
//	public var themeType: ThemeType
//	public var iconAppType: IconAppType
//	public var language: Localizable
//	public var authenticationType: LocalAuthenticationType = .none
//	public var hasPasscode: Bool
//	public var cameraStatus: AuthorizedVideoStatus
//	public var microphoneStatus: AudioRecordPermission
//	public var optionTimeForAskPasscode: Int
//	public var faceIdEnabled: Bool
//	
//	public init(
//		showSplash: Bool,
//		styleType: StyleType,
//		layoutType: LayoutType,
//		themeType: ThemeType,
//		iconAppType: IconAppType,
//		language: Localizable,
//		hasPasscode: Bool,
//		cameraStatus: AuthorizedVideoStatus,
//		microphoneStatus: AudioRecordPermission,
//		optionTimeForAskPasscode: Int,
//		faceIdEnabled: Bool
//	) {
//		self.showSplash = showSplash
//		self.styleType = styleType
//		self.layoutType = layoutType
//		self.themeType = themeType
//		self.iconAppType = iconAppType
//		self.language = language
//		self.hasPasscode = hasPasscode
//		self.cameraStatus = cameraStatus
//		self.microphoneStatus = microphoneStatus
//		self.optionTimeForAskPasscode = optionTimeForAskPasscode
//		self.faceIdEnabled = faceIdEnabled
//	}
//}

@Reducer
public struct Home {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		public var tabBars: [TabViewType]
		public var selectedTabBar: TabViewType
//		public var sharedState: SharedState
		
		public var entries: Entries.State
		public var search: Search.State
		public var settings: SettingsFeature.State
		
		public init(
			entries: Entries.State = Entries.State(),
			tabBars: [TabViewType],
			search: Search.State = Search.State(),
			settings: SettingsFeature.State = SettingsFeature.State(),
			selectedTabBar: TabViewType = .entries
		) {
			self.entries = entries
			self.tabBars = tabBars
			self.search = search
			self.settings = settings
			self.selectedTabBar = selectedTabBar
		}
	}
	
	public enum Action: Equatable {
		case entries(Entries.Action)
		case tabBarSelected(TabViewType)
		case task
		case search(Search.Action)
		case settings(SettingsFeature.Action)
	}
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.entries, action: \.entries) {
			Entries()
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
