import ComposableArchitecture
import EntriesFeature
import FeedbackGeneratorClient
import Foundation
import Models

public struct LayoutFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var layoutType: LayoutType
		public var styleType: StyleType
		public var entries: IdentifiedArrayOf<DayEntriesRow.State>
		
		public init(
			layoutType: LayoutType,
			styleType: StyleType,
			entries: IdentifiedArrayOf<DayEntriesRow.State>
		) {
			self.layoutType = layoutType
			self.styleType = styleType
			self.entries = entries
		}
	}
	
	public enum Action: Equatable {
		case layoutChanged(LayoutType)
		case entries(id: UUID, action: DayEntriesRow.Action)
	}
	
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case let .layoutChanged(appearanceChanged):
					state.layoutType = appearanceChanged
					state.entries = fakeEntries(with: state.styleType, layout: state.layoutType)
					
					return .run { _ in
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
