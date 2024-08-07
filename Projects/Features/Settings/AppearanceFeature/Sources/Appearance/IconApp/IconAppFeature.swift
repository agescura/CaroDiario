import Foundation
import ComposableArchitecture
import Models
import UIApplicationClient

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
	
	@Dependency(\.applicationClient) private var applicationClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case let .iconAppChanged(newIconApp):
					state.userSettings.appearance.iconAppType = newIconApp
					return .run { _ in
						try await self.applicationClient.setAlternateIconName(newIconApp == .dark ? "AppIcon-2" : nil)
					}
			}
		}
	}
}
