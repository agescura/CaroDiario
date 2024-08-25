import ComposableArchitecture
import SwiftUI
import Styles
import EntriesFeature
import Models

public struct LayoutView: View {
	@Bindable var store: StoreOf<LayoutFeature>
	
	public init(
		store: StoreOf<LayoutFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			
			Picker("", selection: $store.userSettings.appearance.layoutType.sending(\.layoutChanged)) {
				ForEach(LayoutType.allCases, id: \.self) { type in
					Text(type.rawValue.localized)
						.foregroundColor(.berryRed)
						.adaptiveFont(.latoRegular, size: 10)
				}
			}
			.frame(height: 60)
			.pickerStyle(SegmentedPickerStyle())
			
			ScrollView(showsIndicators: false) {
				LazyVStack(alignment: .leading, spacing: 8) {
					ForEach(
						Array(store.scope(state: \.entries, action: \.entries)),
						id: \.id
					) { store in
						DayEntriesRowView(store: store)
					}
				}
				.accentColor(.chambray)
				.animation(.default, value: UUID())
				.disabled(true)
			}
			
			Spacer()
		}
		.padding(16)
		.navigationBarTitle("Settings.Layout".localized)
	}
}
