import AppFeature
import ComposableArchitecture
import SwiftUI

public struct RootView: View {
	private let store: StoreOf<RootFeature>
	
	public init(
		store: StoreOf<RootFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		AppView(
			store: self.store.scope(
				state: \.feature,
				action: RootFeature.Action.feature
			)
		)
	}
}

struct RootView_Preview: PreviewProvider {
	static var previews: some View {
		RootView(
			store: Store(
				initialState: RootFeature.State(
					appDelegate: AppDelegateState(),
					feature: .splash(SplashFeature.State())
				),
				reducer: RootFeature()
			)
		)
	}
}

import SplashFeature
