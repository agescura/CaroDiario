import ComposableArchitecture
import EntriesFeature
import Foundation
import Models
import SearchFeature
import SettingsFeature

public struct HomeFeature: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var selectedTab: Tab
		public var userSettings: UserSettings
		
		public var entries: EntriesFeature.State {
			get {
				EntriesFeature.State(
					userSettings: self.userSettings
				)
			}
			set {
				self.userSettings = newValue.userSettings
			}
		}
		public var search: SearchFeature.State {
			get {
				SearchFeature.State()
			}
			set {}
		}
		public var settings: SettingsFeature.State {
			get {
				SettingsFeature.State(
					userSettings: self.userSettings
				)
			}
			set {
				self.userSettings = newValue.userSettings
			}
		}
		
		public init(
			selectedTabBar: Tab = .entries,
			userSettings: UserSettings
		) {
			self.selectedTab = selectedTabBar
			self.userSettings = userSettings
		}
	}
	
	public enum Action: Equatable {
		case tabBarSelected(Tab)
		case starting
		case entries(EntriesFeature.Action)
		case search(SearchFeature.Action)
		case settings(SettingsFeature.Action)
	}
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.entries, action: /Action.entries) {
			EntriesFeature()
		}
		Scope(state: \.settings, action: /Action.settings) {
			SettingsFeature()
		}
		Scope(state: \.search, action: /Action.search) {
			SearchFeature()
		}
		Reduce(self.core)
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
			case let .tabBarSelected(tab):
				state.selectedTab = tab
				return .none
				
			case .starting, .entries, .settings, .search:
				return .none
		}
	}
}
