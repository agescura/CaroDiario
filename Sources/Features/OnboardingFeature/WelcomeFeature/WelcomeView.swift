import SwiftUI
import ComposableArchitecture
import Views

public struct WelcomeView: View {
	let store: StoreOf<WelcomeFeature>
	
	private struct ViewState: Equatable {
		let isAppClip: Bool
		let selectedPage: Int
		let tabViewAnimated: Bool
		
		init(state: WelcomeFeature.State) {
			self.isAppClip = state.isAppClip
			self.selectedPage = state.selectedPage
			self.tabViewAnimated = state.tabViewAnimated
		}
	}
	
	public init(
		store: StoreOf<WelcomeFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: ViewState.init
		) { viewStore in
			NavigationView {
				VStack(alignment: .leading, spacing: 16) {
					Text("OnBoarding.Diary".localized)
						.adaptiveFont(.latoBold, size: 24)
						.foregroundColor(.adaptiveBlack)
					Text("OnBoarding.Welcome".localized)
						.adaptiveFont(.latoItalic, size: 12)
						.foregroundColor(.adaptiveGray)
					
					
					OnBoardingTabView(
						items: [
							.init(id: 0, title: "OnBoarding.Description.1".localized),
							.init(id: 1, title: "OnBoarding.Description.2".localized),
							.init(id: 2, title: "OnBoarding.Description.3".localized)
						],
						selection: viewStore.binding(
							get: \.selectedPage,
							send: WelcomeFeature.Action.selectedPage
						),
						animated: viewStore.tabViewAnimated
					)
					.frame(minHeight: 150)
					
					NavigationLinkStore(
						self.store.scope(
							state: \.$privacy,
							action: WelcomeFeature.Action.privacy
						),
						destination: PrivacyView.init,
						label: EmptyView.init
					)
					
					TerciaryButtonView(
						label: {
							Text("OnBoarding.Skip".localized)
								.adaptiveFont(.latoRegular, size: 16)
							
						}
					) {
						viewStore.send(.alertButtonTapped)
					}
					.opacity(viewStore.isAppClip ? 0.0 : 1.0)
					.padding(.horizontal, 16)
					
					PrimaryButtonView(
						label: {
							Text("OnBoarding.Continue".localized)
								.adaptiveFont(.latoRegular, size: 16)
							
						}
					) {
						viewStore.send(.privacyButtonTapped)
					}
					.padding(.horizontal, 16)
				}
				.padding()
				.navigationBarTitleDisplayMode(.inline)
				.alert(
					store: self.store.scope(
						state: \.$alert,
						action: WelcomeFeature.Action.alert
					)
				)
			}
			.navigationViewStyle(StackNavigationViewStyle())
			.task { await viewStore.send(.selectedPage(0)).finish() }
		}
	}
}

struct WelcomeView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			WelcomeView(
				store: Store(
					initialState: WelcomeFeature.State(),
					reducer: WelcomeFeature()
				)
			)
		}
	}
}
