import ComposableArchitecture
import EntriesFeature
import FeedbackGeneratorClient
import Foundation
import Models

public struct StyleFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable, Identifiable {
		public var styleType: StyleType
		public var layoutType: LayoutType
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		
		public var id: StyleType { self.styleType }
	}
	
	public enum Action: Equatable {
		case styleChanged(StyleType)
		case entries(id: UUID, action: DayEntriesRow.Action)
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case let .styleChanged(styleChanged):
					state.styleType = styleChanged
					state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
					return .fireAndForget {
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
