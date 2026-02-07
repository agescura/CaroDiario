import Foundation
import ComposableArchitecture
import Models
import EntriesFeature

@Reducer
public struct LayoutFeature {
  public init() {}
	
	@ObservableState
	public struct State: Equatable {
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
		public init() {}
	}

  public enum Action: Equatable {
    case layoutChanged(LayoutType)
  }
  
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .layoutChanged(layoutType):
					state.$userSettings.appearance.layoutType.withLock { $0 = layoutType }
					return .none
			}
		}
	}
}
