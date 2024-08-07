import Foundation
import ComposableArchitecture
import Models
import EntriesFeature

@Reducer
public struct LayoutFeature {
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
    case layoutChanged(LayoutType)
    case entries(IdentifiedActionOf<DayEntriesRow>)
  }
  
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .layoutChanged(layoutType):
					state.userSettings.appearance.layoutType = layoutType
					state.entries = fakeEntries
					return .none
					
				case .entries:
					return .none
			}
		}
		.forEach(\.entries, action: \.entries) {
			DayEntriesRow()
		}
	}
}
