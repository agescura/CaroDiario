import ComposableArchitecture
import EntriesFeature
import Localizables
import Models
import SwiftUI
import DesignSystem

@ViewAction(for: ThemeFeature.self)
public struct ThemeView: View {
	@Bindable public var store: StoreOf<ThemeFeature>
	
	public var body: some View {
		VStack {
			ScrollView(showsIndicators: false) {
				VStack(alignment: .leading, spacing: 16) {
					Text("OnBoarding.Theme.Title".localized)
						.adaptiveFont(.latoBold, size: 24)
						.foregroundColor(.adaptiveBlack)
					Text("OnBoarding.Style.Message".localized)
						.foregroundColor(.adaptiveBlack)
						.adaptiveFont(.latoRegular, size: 10)
					Picker("", selection: $store.userSettings.appearance.themeType.sending(\.themeChanged)) {
						ForEach(ThemeType.allCases, id: \.self) { type in
							Text(type.rawValue.localized)
								.foregroundColor(.berryRed)
								.adaptiveFont(.latoRegular, size: 10)
						}
					}
					.pickerStyle(SegmentedPickerStyle())

          DayEntriesView(
            dayEntriesRows: .fakeGroupedEntries,
            layoutType: store.userSettings.appearance.layoutType,
            styleType: store.userSettings.appearance.styleType
          )
					.accentColor(.chambray)
					.animation(.default, value: store.userSettings.appearance.themeType)
					.disabled(true)
					.frame(minHeight: 200)
				}
			}
			
			Button(store.isAppClip ? "App Store" : "OnBoarding.Start".localized) {
				send(.startButtonTapped)
			}
			.buttonStyle(.primary)
		}
		.padding()
		.navigationBarBackButtonHidden(true)
	}
}
