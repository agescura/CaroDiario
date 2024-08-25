import ComposableArchitecture
import Styles
import SwiftUI
import Views

@ViewAction(for: WelcomeFeature.self)
public struct WelcomeView: View {
	@Bindable public var store: StoreOf<WelcomeFeature>
	
	public init(
		store: StoreOf<WelcomeFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		NavigationStack(path: self.$store.scope(state: \.path, action: \.path)) {
			VStack(alignment: .leading, spacing: 16) {
				Text("OnBoarding.Diary".localized)
					.textStyle(.title)
				Text("OnBoarding.Welcome".localized)
					.textStyle(.body)
				
				OnBoardingTabView(
					items: [
						.init(id: 0, title: "OnBoarding.Description.1".localized),
						.init(id: 1, title: "OnBoarding.Description.2".localized),
						.init(id: 2, title: "OnBoarding.Description.3".localized)
					],
					selection: $store.selectedPage.sending(\.selectedPage),
					animated: store.tabViewAnimated
				)
				.frame(minHeight: 150)
				
				
				Button("OnBoarding.Skip".localized) {
					send(.skipAlertButtonTapped)
				}
				.buttonStyle(.secondary)
				.opacity(store.isAppClip ? 0.0 : 1.0)
				
				Button("OnBoarding.Continue".localized) {
					send(.privacyButtonTapped)
				}
				.buttonStyle(.primary)
			}
			.padding()
			.navigationBarTitleDisplayMode(.inline)
			.alert(
				store: store.scope(state: \.$alert, action: \.alert)
			)
		} destination: { store in
			switch store.case {
				case let .layout(store):
					LayoutView(store: store)
				case let .privacy(store):
					PrivacyView(store: store)
				case let .style(store):
					StyleView(store: store)
				case let .theme(store):
					ThemeView(store: store)
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.task {
			await send(.task).finish()
		}
	}
}

#Preview {
	WelcomeView(
		store: Store(
			initialState: WelcomeFeature.State(),
			reducer: { WelcomeFeature() }
		)
	)
}
