import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import Models
import EntriesFeature
import Styles

public struct ThemeView: View {
	@Perception.Bindable var store: StoreOf<ThemeFeature>
	
	public var body: some View {
		WithPerceptionTracking {
			VStack {
				ScrollView(showsIndicators: false) {
					VStack(alignment: .leading, spacing: 16) {
						Text("OnBoarding.Theme.Title".localized)
							.adaptiveFont(.latoBold, size: 24)
							.foregroundColor(.adaptiveBlack)
						Text("OnBoarding.Style.Message".localized)
							.foregroundColor(.adaptiveBlack)
							.adaptiveFont(.latoRegular, size: 10)
						Picker("", selection: self.$store.userSettings.appearance.themeType.sending(\.themeChanged)) {
							ForEach(ThemeType.allCases, id: \.self) { type in
								Text(type.rawValue.localized)
									.foregroundColor(.berryRed)
									.adaptiveFont(.latoRegular, size: 10)
							}
						}
						.pickerStyle(SegmentedPickerStyle())
						LazyVStack(alignment: .leading, spacing: 8) {
							ForEach(
								self.store.scope(state: \.entries, action: \.entries),
								id: \.id,
								content: DayEntriesRowView.init
							)
						}
						.accentColor(.chambray)
						.animation(.default, value: UUID())
						.disabled(true)
						.frame(minHeight: 200)
					}
				}
				
				PrimaryButtonView(
					label: {
						Text(self.store.isAppClip ? "Instalar en App Store" : "OnBoarding.Start".localized)
							.adaptiveFont(.latoRegular, size: 16)
					}) {
						self.store.send(.startButtonTapped)
					}
					.padding(.horizontal, 16)
			}
			.padding()
			.navigationBarBackButtonHidden(true)
		}
	}
}
