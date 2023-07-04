import ComposableArchitecture
import FeedbackGeneratorClient
import EntriesFeature
import Foundation
import Models
import UserDefaultsClient

public struct ThemeFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var isAppClip: Bool
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var themeType: ThemeType
		
		public init(
			isAppClip: Bool = false,
			entries: IdentifiedArrayOf<DayEntriesRow.State>,
			themeType: ThemeType
		) {
			self.isAppClip = isAppClip
			self.entries = entries
			self.themeType = themeType
		}
	}
	
	public enum Action: Equatable {
		case delegate(Delegate)
		case entries(id: UUID, action: DayEntriesRow.Action)
		case themeChanged(ThemeType)
		case finishButtonTapped
		
		public enum Delegate: Equatable {
			case finished
		}
	}
	
	@Dependency(\.applicationClient.setUserInterfaceStyle) private var setUserInterfaceStyle
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .delegate:
					return .none
					
				case .entries:
					return .none
					
				case .finishButtonTapped:
					return .run { send in
						await send(.delegate(.finished))
					}
					
				case let .themeChanged(themeChanged):
					state.themeType = themeChanged
					return .run { _ in
						await self.setUserInterfaceStyle(themeChanged.userInterfaceStyle)
						await self.feedbackGeneratorClient.selectionChanged()
					}
			}
					
		}
		.forEach(\.entries, action: /Action.entries) {
			DayEntriesRow()
		}
	}
}
