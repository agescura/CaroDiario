import ComposableArchitecture
import EntriesFeature
import Localizables
import Models
import SwiftUI
import DesignSystem

@ViewAction(for: StyleFeature.self)
public struct StyleView: View {
	@Bindable public var store: StoreOf<StyleFeature>
	
	public var body: some View {
		VStack {
			ScrollView(showsIndicators: false) {
				VStack(alignment: .leading, spacing: 16) {
					
					Text("OnBoarding.Style.Title".localized)
						.adaptiveFont(.latoBold, size: 24)
						.foregroundColor(.adaptiveBlack)
					
					Text("OnBoarding.Style.Message".localized)
						.foregroundColor(.adaptiveGray)
						.adaptiveFont(.latoRegular, size: 10)
					
					Picker("", selection: $store.userSettings.appearance.styleType.sending(\.styleChanged)
					) {
						ForEach(StyleType.allCases, id: \.self) { type in
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
					.animation(.default, value: store.userSettings.appearance.styleType)
					.disabled(true)
					.frame(minHeight: 200)
				}
			}
			
			Button("OnBoarding.Skip".localized) {
				send(.skipAlertButtonTapped)
			}
			.buttonStyle(.secondary)
			.opacity(store.isAppClip ? 0.0 : 1.0)
			
			Button("OnBoarding.Continue".localized) {
				send(.layoutButtonTapped)
			}
			.buttonStyle(.primary)
		}
    .padding()
    .navigationBarBackButtonHidden(true)
    .alert(
      $store.scope(
        state: \.alert,
        action: \.alert
      )
    )
  }
}

#Preview {
  StyleView(
		store: Store(
			initialState: StyleFeature.State(
//				entries: fakeEntries
			),
			reducer: { StyleFeature() }
		)
	)
}
