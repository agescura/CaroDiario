import ComposableArchitecture
import EntriesFeature
import Styles
import SwiftUI
import TCAHelpers
import Views

public struct PrivacyView: View {
	let store: StoreOf<PrivacyFeature>
	
	public init(
		store: StoreOf<PrivacyFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: \.isAppClip
		) { viewStore in
			VStack(alignment: .leading, spacing: 16) {
				Text("OnBoarding.Important".localized)
					.adaptiveFont(.latoRegular, size: 24)
					.foregroundColor(.adaptiveBlack)
				
				HStack(alignment: .center) {
					Image(.handRaised)
						.resizable()
						.foregroundColor(.adaptiveGray)
						.scaledToFill()
						.frame(width: 18, height: 18)
						.offset(y: 8)
					
					Text("OnBoarding.Privacy".localized)
						.adaptiveFont(.latoItalic, size: 12)
						.foregroundColor(.adaptiveGray)
				}
				
				Spacer()
				
				NavigationLinkStore(
					self.store.scope(
						state: \.$style,
						action: PrivacyFeature.Action.style
					),
					destination: StyleView.init,
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
				.opacity(viewStore.state ? 0.0 : 1.0)
				.padding(.horizontal, 16)
				
				PrimaryButtonView(
					label: {
						Text("OnBoarding.Continue".localized)
							.adaptiveFont(.latoRegular, size: 16)
					}
				) {
					viewStore.send(.styleButtonTapped)
				}
				.padding(.horizontal, 16)
			}
			.padding()
			.navigationBarBackButtonHidden(true)
			.alert(
				store: self.store.scope(
					state: \.$alert,
					action: PrivacyFeature.Action.alert
				)
			)
		}
	}
}
