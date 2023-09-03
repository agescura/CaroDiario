import ComposableArchitecture
import SwiftUI
import UserDefaultsClient
import FeedbackGeneratorClient
import UIApplicationClient

public struct ClipFeature: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var featureState: SwitchClipFeature.State
		
		public init(
			featureState: SwitchClipFeature.State
		) {
			self.featureState = featureState
		}
	}
	
	public enum Action: Equatable {
		case featureAction(SwitchClipFeature.Action)
		case onAppear
	}
	
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.applicationClient) private var applicationClient
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.featureState, action: /Action.featureAction) {
			SwitchClipFeature()
		}
		Reduce { state, action in
			switch action {
				case .onAppear:
					return .send(.featureAction(.splash(.startAnimation)))
					
				case .featureAction(.onBoarding(.destination(.presented(.privacy(.destination(.presented(.style(.destination(.presented(.layout(.destination(.presented(.theme(.startButtonTapped)))))))))))))):
					return .run { _ in
						self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
						await self.applicationClient.open(URL(string: "itms-apps://itunes.apple.com/app/apple-store/id375380948?mt=8")!, [:])
					}
					
				case .featureAction(.splash(.animation(.finish))):
					state.featureState = .onBoarding(.init(isAppClip: true))
					return .none
					
				case .featureAction:
					return .none
			}
		}
	}
}

public struct ClipView: View {
	private let store: StoreOf<ClipFeature>
	
	public init(
		store: StoreOf<ClipFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		SwitchClipView(
			store: store.scope(
				state: \.featureState,
				action: ClipFeature.Action.featureAction
			)
		)
		.onAppear {
			self.store.send(.onAppear)
		}
	}
}
