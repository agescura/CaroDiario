import ComposableArchitecture
import EntriesFeature
import Models
import Styles
import SwiftUI

public struct StyleView: View {
	let store: StoreOf<StyleFeature>
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			VStack(alignment: .leading, spacing: 16) {
				
				Picker(
					"",
					selection: viewStore.binding(
						get: \.styleType,
						send: StyleFeature.Action.styleChanged
					)
				) {
					ForEach(StyleType.allCases, id: \.self) { type in
						Text(type.rawValue.localized)
							.foregroundColor(.berryRed)
							.adaptiveFont(.latoRegular, size: 10)
					}
				}
				.frame(height: 60)
				.pickerStyle(SegmentedPickerStyle())
				
				ScrollView(showsIndicators: false) {
					LazyVStack(alignment: .leading, spacing: 8) {
						ForEachStore(
							store.scope(
								state: \.entries,
								action: StyleFeature.Action.entries(id:action:)),
							content: DayEntriesRowView.init(store:)
						)
					}
					.accentColor(.chambray)
					.animation(.default, value: UUID())
					.disabled(true)
				}
				
				Spacer()
			}
			.padding(16)
			.navigationBarTitle("Settings.Style".localized)
		}
	}
}

struct StyleView_Previews: PreviewProvider {
	static var previews: some View {
		StyleView(
			store: Store(
				initialState: StyleFeature.State(
					styleType: .rectangle,
					layoutType: .horizontal,
					entries: fakeEntries(
						with: .rectangle,
						layout: .horizontal
					)
					
				),
				reducer: StyleFeature()
			)
		)
		.previewDisplayName("Rectangle")
		
		StyleView(
			store: Store(
				initialState: StyleFeature.State(
					styleType: .rounded,
					layoutType: .horizontal,
					entries: fakeEntries(
						with: .rounded,
						layout: .horizontal
					)
					
				),
				reducer: StyleFeature()
			)
		)
		.previewDisplayName("Rounded")
	}
}
