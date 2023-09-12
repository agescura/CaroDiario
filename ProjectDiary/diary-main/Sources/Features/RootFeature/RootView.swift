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
				state: \.app,
				action: RootFeature.Action.app
			)
		)
	}
}
