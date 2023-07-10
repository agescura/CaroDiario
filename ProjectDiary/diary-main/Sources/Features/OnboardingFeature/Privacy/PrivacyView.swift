import ComposableArchitecture
import EntriesFeature
import Styles
import SwiftUI
import Views

public struct PrivacyView: View {
	private let store: StoreOf<PrivacyFeature>
	
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
					Image(systemName: "hand.raised")
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
						state: \.$destination,
						action: PrivacyFeature.Action.destination
					),
					state: /PrivacyFeature.Destination.State.style,
					action: PrivacyFeature.Destination.Action.style,
					destination: StyleView.init
				)
				
				TerciaryButtonView(
					label: {
						Text("OnBoarding.Skip".localized)
							.adaptiveFont(.latoRegular, size: 16)
						
					}) {
						viewStore.send(.alertButtonTapped)
					}
					.opacity(viewStore.state ? 0.0 : 1.0)
					.padding(.horizontal, 16)
				
				PrimaryButtonView(
					label: {
						Text("OnBoarding.Continue".localized)
							.adaptiveFont(.latoRegular, size: 16)
					}) {
						viewStore.send(.styleButtonTapped)
					}
					.padding(.horizontal, 16)
			}
			.padding()
			.navigationBarBackButtonHidden(true)
			.alert(
				store: self.store.scope(
					state: \.$destination,
					action: PrivacyFeature.Action.destination
				),
				state: /PrivacyFeature.Destination.State.alert,
				action: PrivacyFeature.Destination.Action.alert
			)
		}
	}
}
