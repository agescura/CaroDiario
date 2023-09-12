import ComposableArchitecture
import EntriesFeature
import FeedbackGeneratorClient
import Foundation
import Models
import UIApplicationClient
import UserDefaultsClient

public struct ThemeFeature: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var themeType: ThemeType = .system
	}
	
	public enum Action: Equatable {
		case themeChanged(ThemeType)
		case entries(id: UUID, action: DayEntriesRow.Action)
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.applicationClient.setUserInterfaceStyle) private var setUserInterfaceStyle
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .themeChanged(newTheme):
					state.themeType = newTheme
					return .run { _ in
						await self.setUserInterfaceStyle(newTheme.userInterfaceStyle)
						await self.feedbackGeneratorClient.selectionChanged()
					}
				case .entries:
					return .none
			}
		}
		.forEach(\.entries, action: /Action.entries) {
			DayEntriesRow()
		}
	}
}
