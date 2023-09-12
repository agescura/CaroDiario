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
import AVAudioPlayerClient
import AVAudioRecorderClient
import StoreKitClient
import PDFKitClient
import AVAssetClient
import Styles
import EntryDetailFeature

public struct SharedState: Equatable {
	public var isLoading: Bool = true
	public var destination: EntriesFeature.Destination.State?
	public var entries: IdentifiedArrayOf<DayEntriesRow.State> = []
	
	public var search: SearchFeature.State = SearchFeature.State()
	
	public var showSplash: Bool
	public var styleType: StyleType
	public var layoutType: LayoutType
	public var themeType: ThemeType
	public var iconAppType: IconAppType
	public var language: Localizable
	public var authenticationType: LocalAuthenticationType = .none
	public var hasPasscode: Bool
	public var cameraStatus: AuthorizedVideoStatus
	public var recordPermission: RecordPermission
	public var optionTimeForAskPasscode: Int
	public var faceIdEnabled: Bool
	
	public init(
		showSplash: Bool,
		styleType: StyleType,
		layoutType: LayoutType,
		themeType: ThemeType,
		iconAppType: IconAppType,
		language: Localizable,
		hasPasscode: Bool,
		cameraStatus: AuthorizedVideoStatus,
		recordPermission: RecordPermission,
		optionTimeForAskPasscode: Int,
		faceIdEnabled: Bool
	) {
		self.showSplash = showSplash
		self.styleType = styleType
		self.layoutType = layoutType
		self.themeType = themeType
		self.iconAppType = iconAppType
		self.language = language
		self.hasPasscode = hasPasscode
		self.cameraStatus = cameraStatus
		self.recordPermission = recordPermission
		self.optionTimeForAskPasscode = optionTimeForAskPasscode
		self.faceIdEnabled = faceIdEnabled
	}
}

public struct HomeView: View {
	private let store: StoreOf<HomeFeature>
	
	public init(
		store: StoreOf<HomeFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: \.selectedTab
		) { viewStore in
			TabView(
				selection: viewStore.binding(send: HomeFeature.Action.tabBarSelected)
			) {
				EntriesView(
					store: store.scope(
						state: \.entries,
						action: HomeFeature.Action.entries
					)
				)
				.tabItem {
					VStack {
						Image(systemName: "note.text")
						Text("Home.TabView.Entries".localized)
					}
				}
				
				SearchView(
					store: store.scope(
						state: \.search,
						action: HomeFeature.Action.search
					)
				)
				.tabItem {
					VStack {
						Image(systemName: "magnifyingglass")
						Text("Home.TabView.Search".localized)
					}
				}
				
				SettingsView(
					store: store.scope(
						state: \.settings,
						action: HomeFeature.Action.settings
					)
				)
				.tabItem {
					VStack {
						Image(systemName: "gear")
						Text("Home.TabView.Settings".localized)
					}
				}
			}
			.accentColor(.chambray)
		}
		.accentColor(.chambray)
	}
}

struct HomeView_Previews: PreviewProvider {
	static var previews: some View {
		HomeView(
			store: Store(
				initialState: HomeFeature.State(
					userSettings: .defaultValue
				),
				reducer: HomeFeature.init
			)
		)
	}
}
