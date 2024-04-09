import Foundation
import ComposableArchitecture
import Models
import EntriesFeature

@Reducer
public struct ThemeFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var isAppClip = false
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
	}
	
	public enum Action: Equatable {
		case delegate(Delegate)
		case entries(IdentifiedActionOf<DayEntriesRow>)
		case startButtonTapped
		case themeChanged(ThemeType)
		
		@CasePathable
		public enum Delegate: Equatable {
			case navigateToHome
		}
	}
	
	@Dependency(\.applicationClient.setUserInterfaceStyle) private var setUserInterfaceStyle
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .delegate:
					return .none
					
				case .entries:
					return .none
					
				case .startButtonTapped:
					state.userSettings.hasShownOnboarding = true
					return .send(.delegate(.navigateToHome))
					
				case let .themeChanged(themeType):
					state.userSettings.appearance.themeType = themeType
					return .run { _ in
						await self.setUserInterfaceStyle(themeType.userInterfaceStyle)
					}
			}
		}
		.forEach(\.entries, action: \.entries) {
			DayEntriesRow()
		}
	}
}
