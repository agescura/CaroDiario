import ComposableArchitecture
import SwiftUI
import UserDefaultsClient
import FeedbackGeneratorClient
import UIApplicationClient

public struct Clip: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var featureState: SwitchClip.State
		
		public init(
			featureState: SwitchClip.State
		) {
			self.featureState = featureState
		}
	}
	
	public enum Action: Equatable {
		case featureAction(SwitchClip.Action)
		case onAppear
	}
	
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	@Dependency(\.applicationClient) private var applicationClient
	
	public var body: some ReducerOf<Self> {
		Reduce(self.core)
		Scope(state: \State.featureState, action: /Action.featureAction) {
			SwitchClip()
		}
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
			case .onAppear:
				return .send(Action.featureAction(.splash(.startAnimation)))
				
			case .featureAction(.onBoarding(.privacy(.style(.layout(.theme(.startButtonTapped)))))):
				return .run { _ in
					await self.userDefaultsClient.setHasShownFirstLaunchOnboarding(true)
					await self.applicationClient.open(URL(string: "itms-apps://itunes.apple.com/app/apple-store/id375380948?mt=8")!, [:])
				}
				
			case .featureAction(.splash(.finishAnimation)):
				state.featureState = .onBoarding(.init(isAppClip: true))
				return .none
				
			case .featureAction:
				return .none
		}
	}
}

public struct ClipView: View {
	let store: StoreOf<Clip>
	
	public init(
		store: StoreOf<Clip>
	) {
		self.store = store
	}
	
	public var body: some View {
		SwitchClipView(
			store: store.scope(
				state: \.featureState,
				action: Clip.Action.featureAction
			)
		)
		.onAppear {
			self.store.send(.onAppear)
		}
	}
}
