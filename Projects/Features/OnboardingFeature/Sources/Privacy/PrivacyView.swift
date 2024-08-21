import SwiftUI
import ComposableArchitecture
import Views
import Styles
import EntriesFeature

@ViewAction(for: PrivacyFeature.self)
public struct PrivacyView: View {
	public let store: StoreOf<PrivacyFeature>
	
	public init(
		store: StoreOf<PrivacyFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
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
			
			TerciaryButtonView(
				label: {
					Text("OnBoarding.Skip".localized)
						.adaptiveFont(.latoRegular, size: 16)
					
				}) {
					send(.skipAlertButtonTapped)
				}
				.opacity(store.isAppClip ? 0.0 : 1.0)
				.padding(.horizontal, 16)
				.alert(store: store.scope(state: \.$alert, action: \.alert))
			
			PrimaryButtonView(
				label: {
					Text("OnBoarding.Continue".localized)
						.adaptiveFont(.latoRegular, size: 16)
				}) {
					send(.styleButtonTapped)
				}
				.padding(.horizontal, 16)
		}
		.padding()
		.navigationBarBackButtonHidden(true)
	}
}
