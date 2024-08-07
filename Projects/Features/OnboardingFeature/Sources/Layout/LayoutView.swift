import ComposableArchitecture
import SwiftUI
import EntriesFeature
import Views
import Styles
import UserDefaultsClient
import Models

public struct LayoutView: View {
	@Bindable var store: StoreOf<LayoutFeature>
	
	public init(
		store: StoreOf<LayoutFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		VStack {
			ScrollView(showsIndicators: false) {
				VStack(alignment: .leading, spacing: 16) {
					
					Text("OnBoarding.Layout.Title".localized)
						.adaptiveFont(.latoBold, size: 24)
						.foregroundColor(.adaptiveBlack)
					
					Text("OnBoarding.Appearance.Message".localized)
						.adaptiveFont(.latoItalic, size: 10)
						.foregroundColor(.adaptiveGray)
					
					
					Picker("", selection: self.$store.userSettings.appearance.layoutType.sending(\.layoutChanged)) {
						ForEach(LayoutType.allCases, id: \.self) { type in
							Text(type.rawValue.localized)
						}
					}
					.pickerStyle(SegmentedPickerStyle())
					
					LazyVStack(alignment: .leading, spacing: 8) {
						ForEach(
							self.store.scope(state: \.entries, action: \.entries),
							id: \.id,
							content: DayEntriesRowView.init(store:)
						)
					}
					.accentColor(.chambray)
					.animation(.default, value: UUID())
					.disabled(true)
					.frame(minHeight: 200)
				}
			}
			
			TerciaryButtonView(
				label: {
					Text("OnBoarding.Skip".localized)
						.adaptiveFont(.latoRegular, size: 16)
					
				}) {
					self.store.send(.skipAlertButtonTapped)
				}
				.opacity(self.store.isAppClip ? 0.0 : 1.0)
				.padding(.horizontal, 16)
				.alert(
					store: self.store.scope(state: \.$alert, action: \.alert)
				)
			
			PrimaryButtonView(
				label: {
					Text("OnBoarding.Continue".localized)
						.adaptiveFont(.latoRegular, size: 16)
				}) {
					self.store.send(.themeButtonTapped)
				}
				.padding(.horizontal, 16)
		}
		.padding()
		.navigationBarBackButtonHidden(true)
	}
}

#Preview {
	LayoutView(
		store: Store(
			initialState: LayoutFeature.State(
				entries: fakeEntries
			),
			reducer: { LayoutFeature() }
		)
	)
}
