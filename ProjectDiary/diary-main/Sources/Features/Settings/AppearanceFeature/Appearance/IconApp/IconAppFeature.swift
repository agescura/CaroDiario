import Foundation
import ComposableArchitecture
import Models
import UIApplicationClient
import FeedbackGeneratorClient

public struct IconAppFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable, Identifiable {
		public var iconAppType: IconAppType
		
		public var id: IconAppType { self.iconAppType }
		
		public init(
			iconAppType: IconAppType
		) {
			self.iconAppType = iconAppType
		}
	}
	
	public enum Action: Equatable {
		case iconAppChanged(IconAppType)
	}
	
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case let .iconAppChanged(newIconApp):
					state.iconAppType = newIconApp
					return .fireAndForget {
						try await self.applicationClient.setAlternateIconName(newIconApp == .dark ? "AppIcon-2" : nil)
						await self.feedbackGeneratorClient.selectionChanged()
					}
			}
		}
	}
}
