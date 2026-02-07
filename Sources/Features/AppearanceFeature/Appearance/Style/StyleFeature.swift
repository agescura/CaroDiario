import ComposableArchitecture
import Foundation
//import EntriesFeature
import Models

@Reducer
public struct StyleFeature {
  public init() {}
  
	@ObservableState
  public struct State: Equatable {
    @Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
		public init() {}
  }

  public enum Action: Equatable {
    case styleChanged(StyleType)
  }
  
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .styleChanged(styleType):
					state.$userSettings.appearance.styleType.withLock { $0 = styleType }
					return .none
			}
		}
	}
}
