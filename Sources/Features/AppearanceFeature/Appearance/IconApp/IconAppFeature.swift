import Foundation
import ComposableArchitecture
import Models
import ApplicationClient

@Reducer
public struct IconAppFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
		public init() {}
	}
	
	public enum Action: Equatable {
		case iconAppChanged(IconAppType)
	}
	
  @Dependency(\.applicationClient.setAlternateIconName) private var setAlternateIconName
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .iconAppChanged(newIconApp):
					state.$userSettings.appearance.iconAppType.withLock { $0 = newIconApp }
					return .run { [setAlternateIconName] _ in
						try await setAlternateIconName(newIconApp == .dark ? "AppIcon-2" : nil)
					}
			}
		}
	}
}
