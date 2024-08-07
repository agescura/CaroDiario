import Foundation
import ComposableArchitecture
import Models
import UIApplicationClient
import UserDefaultsClient
import EntriesFeature

@Reducer
public struct ThemeFeature {
  public init() {}
  
	@ObservableState
	public struct State: Equatable {
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
		public init(
			entries: IdentifiedArrayOf<DayEntriesRow.State>
		) {
			self.entries = entries
		}
	}
	
	public enum Action: Equatable {
		case themeChanged(ThemeType)
		case entries(IdentifiedActionOf<DayEntriesRow>)
	}
	
	@Dependency(\.applicationClient.setUserInterfaceStyle) var setUserInterfaceStyle
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .themeChanged(newTheme):
					state.userSettings.appearance.themeType = newTheme
					return .run { _ in
						await self.setUserInterfaceStyle(newTheme.userInterfaceStyle)
					}
				case .entries:
					return .none
			}
		}
		.forEach(\.entries, action: \.entries) {
			DayEntriesRow()
		}
	}
}
