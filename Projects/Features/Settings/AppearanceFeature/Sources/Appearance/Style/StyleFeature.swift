import Foundation
import ComposableArchitecture
import EntriesFeature
import Models

@Reducer
public struct StyleFeature {
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
    case styleChanged(StyleType)
    case entries(IdentifiedActionOf<DayEntriesRow>)
  }
  
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .styleChanged(styleType):
					state.userSettings.appearance.styleType = styleType
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
