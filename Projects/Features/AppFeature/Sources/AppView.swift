import ComposableArchitecture
import Foundation
import HomeFeature
import LockScreenFeature
import OnboardingFeature
import SplashFeature
import SwiftUI

public struct AppView: View {
	let store: StoreOf<AppFeature>
	
	public init(
		store: StoreOf<AppFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		switch self.store.scope(state: \.scene, action: \.scene).case {
			case let .splash(store):
				SplashView(store: store)
			case let .onboarding(store):
				WelcomeView(store: store)
			case let .lockScreen(store):
				LockScreenView(store: store)
			case let .home(store):
				HomeView(store: store)
		}
	}
}
