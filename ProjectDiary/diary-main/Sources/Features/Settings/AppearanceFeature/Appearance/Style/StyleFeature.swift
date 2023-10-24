import ComposableArchitecture
import EntriesFeature
import FeedbackGeneratorClient
import Foundation
import Models

public struct StyleFeature: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		public var layoutType: LayoutType
		public var styleType: StyleType
	}
	
	public enum Action: Equatable {
		case entries(id: UUID, action: DayEntriesRow.Action)
		case styleChanged(StyleType)
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .entries:
					return .none
					
				case let .styleChanged(styleChanged):
					state.styleType = styleChanged
					state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
					return .run { _ in
						await self.feedbackGeneratorClient.selectionChanged()
					}
			}
		}
		.forEach(\.entries, action: /Action.entries) {
			DayEntriesRow()
		}
	}
}
