import Foundation
import ComposableArchitecture
import UserDefaultsClient
import FeedbackGeneratorClient
import Models
import EntriesFeature

public struct Theme: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var themeType: ThemeType
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		
		public var isAppClip = false
	}
	
	public enum Action: Equatable {
		case themeChanged(ThemeType)
		case entries(id: UUID, action: DayEntriesRow.Action)
		
		case startButtonTapped
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	@Dependency(\.applicationClient.setUserInterfaceStyle) private var setUserInterfaceStyle
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce(self.core)
			.forEach(\.entries, action: /Action.entries) {
				DayEntriesRow()
			}
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> EffectTask<Action> {
		switch action {
			case let .themeChanged(themeChanged):
				state.themeType = themeChanged
				return .fireAndForget {
					await self.setUserInterfaceStyle(themeChanged.userInterfaceStyle)
					await self.feedbackGeneratorClient.selectionChanged()
				}
				
			case .entries:
				return .none
				
			case .startButtonTapped:
				return .run { send in
					await self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
				}
		}
	}
}
