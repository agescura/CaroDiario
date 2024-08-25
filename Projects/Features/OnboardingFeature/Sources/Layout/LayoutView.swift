import ComposableArchitecture
import EntriesFeature
import Models
import Styles
import SwiftUI
import UserDefaultsClient
import Views

@ViewAction(for: LayoutFeature.self)
public struct LayoutView: View {
	@Bindable public var store: StoreOf<LayoutFeature>
	
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
					
					
					Picker("", selection: $store.userSettings.appearance.layoutType.sending(\.layoutChanged)) {
						ForEach(LayoutType.allCases, id: \.self) { type in
							Text(type.rawValue.localized)
						}
					}
					.pickerStyle(SegmentedPickerStyle())
					
					LazyVStack(alignment: .leading, spacing: 8) {
						ForEach(
							store.scope(state: \.entries, action: \.entries),
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
			
			Button("OnBoarding.Skip".localized) {
				send(.skipAlertButtonTapped)
			}
			.buttonStyle(.secondary)
			.opacity(store.isAppClip ? 0.0 : 1.0)
			
			Button("OnBoarding.Continue".localized) {
				send(.themeButtonTapped)
			}
			.buttonStyle(.primary)
		}
		.padding()
		.navigationBarBackButtonHidden(true)
		.alert(
			store: store.scope(
				state: \.$alert,
				action: \.alert
			)
		)
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
