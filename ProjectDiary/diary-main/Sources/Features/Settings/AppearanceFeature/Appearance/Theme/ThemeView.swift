import ComposableArchitecture
import EntriesFeature
import FeedbackGeneratorClient
import Models
import Styles
import SwiftUI
import UserDefaultsClient

public struct ThemeView: View {
	private let store: StoreOf<ThemeFeature>
	
	init(
		store: StoreOf<ThemeFeature>
	) {
		self.store = store
		
		UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.chambray)
		UISegmentedControl.appearance().backgroundColor = UIColor(.adaptiveGray).withAlphaComponent(0.1)
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: \.themeType
		) { viewStore in
			VStack(alignment: .leading, spacing: 16) {
				Picker(
					"",
					selection: viewStore.binding(
						get: { _ in viewStore.state },
						send: ThemeFeature.Action.themeChanged
					)
				) {
					ForEach(ThemeType.allCases, id: \.self) { type in
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
								action: ThemeFeature.Action.entries(id:action:)),
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
			.navigationBarTitle("Settings.Theme".localized)
		}
	}
}

struct ThemeView_Previews: PreviewProvider {
	static var previews: some View {
		ThemeView(
			store: Store(
				initialState: ThemeFeature.State(
					themeType: .system,
					entries: fakeEntries(
						with: .rectangle,
						layout: .horizontal
					)
				),
				reducer: ThemeFeature()
			)
		)
		.previewDisplayName("System")
		
		ThemeView(
			store: Store(
				initialState: ThemeFeature.State(
					themeType: .light,
					entries: fakeEntries(
						with: .rectangle,
						layout: .horizontal
					)
				),
				reducer: ThemeFeature()
			)
		)
		.previewDisplayName("Light")
		
		ThemeView(
			store: Store(
				initialState: ThemeFeature.State(
					themeType: .dark,
					entries: fakeEntries(
						with: .rectangle,
						layout: .horizontal
					)
				),
				reducer: ThemeFeature()
			)
		)
		.previewDisplayName("Dark")
	}
}
