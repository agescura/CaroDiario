import Foundation
import ComposableArchitecture
import Models
import FeedbackGeneratorClient
import UIApplicationClient
import UserDefaultsClient
import EntriesFeature

public struct ThemeFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable, Identifiable {
		public var themeType: ThemeType = .system
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		
		public var id: ThemeType { self.themeType }
	}
	
	public enum Action: Equatable {
		case themeChanged(ThemeType)
		case entries(id: UUID, action: DayEntriesRow.Action)
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.applicationClient.setUserInterfaceStyle) private var setUserInterfaceStyle
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case let .themeChanged(newTheme):
					state.themeType = newTheme
					return .fireAndForget {
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
