import ComposableArchitecture
import EntriesFeature
import Localizables
import Models
import Styles
import SwiftUI
import Views

public struct ThemeView: View {
	private let store: StoreOf<ThemeFeature>
	
	private struct ViewState: Equatable {
		let isAppClip: Bool
		let themeType: ThemeType
		init(
			state: ThemeFeature.State
		) {
			self.isAppClip = state.isAppClip
			self.themeType = state.themeType
		}
	}
	public init(
		store: StoreOf<ThemeFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: ViewState.init
		) { viewStore in
			VStack {
				ScrollView(showsIndicators: false) {
					VStack(alignment: .leading, spacing: 16) {
						Text("OnBoarding.Theme.Title".localized)
							.adaptiveFont(.latoBold, size: 24)
							.foregroundColor(.adaptiveBlack)
						Text("OnBoarding.Style.Message".localized)
							.foregroundColor(.adaptiveBlack)
							.adaptiveFont(.latoRegular, size: 10)
						Picker("",  selection: viewStore.binding(
							get: \.themeType,
							send: ThemeFeature.Action.themeChanged
						)) {
							ForEach(ThemeType.allCases, id: \.self) { type in
								Text(type.rawValue.localized)
									.foregroundColor(.berryRed)
									.adaptiveFont(.latoRegular, size: 10)
							}
						}
						.pickerStyle(SegmentedPickerStyle())
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
						.frame(minHeight: 200)
					}
				}
				
				PrimaryButtonView(
					label: {
						Text(viewStore.isAppClip ? "Instalar en App Store" : "OnBoarding.Start".localized)
							.adaptiveFont(.latoRegular, size: 16)
					}
				) {
					viewStore.send(.finishButtonTapped)
				}
				.padding(.horizontal, 16)
			}
			.padding()
			.navigationBarBackButtonHidden(true)
		}
	}
}
