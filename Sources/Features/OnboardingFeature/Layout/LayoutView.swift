import ComposableArchitecture
import SwiftUI
import EntriesFeature
import Views
import Styles
import UserDefaultsClient
import FeedbackGeneratorClient
import Models

public struct LayoutView: View {
	private let store: StoreOf<LayoutFeature>
	
	private struct ViewState: Equatable {
		let isAppClip: Bool
		let layoutType: LayoutType
		
		init(state: LayoutFeature.State) {
			self.isAppClip = state.isAppClip
			self.layoutType = state.layoutType
		}
	}
	
	public init(
		store: StoreOf<LayoutFeature>
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
						
						Text("OnBoarding.Layout.Title".localized)
							.adaptiveFont(.latoBold, size: 24)
							.foregroundColor(.adaptiveBlack)
						
						Text("OnBoarding.Appearance.Message".localized)
							.adaptiveFont(.latoItalic, size: 10)
							.foregroundColor(.adaptiveGray)
						
						
						Picker(
							"",
							selection: viewStore.binding(
								get: \.layoutType,
								send: LayoutFeature.Action.layoutChanged
							)
						) {
							ForEach(LayoutType.allCases, id: \.self) { type in
								Text(type.rawValue.localized)
							}
						}
						.pickerStyle(SegmentedPickerStyle())
						
						LazyVStack(
							alignment: .leading,
							spacing: 8
						) {
							ForEachStore(
								store.scope(
									state: \.entries,
									action: LayoutFeature.Action.entries(id:action:)
								),
								content: DayEntriesRowView.init(store:)
							)
						}
						.accentColor(.chambray)
						.animation(.default, value: UUID())
						.disabled(true)
						.frame(minHeight: 200)
					}
				}
				
				NavigationLinkStore(
					self.store.scope(
						state: \.$theme,
						action: LayoutFeature.Action.theme
					),
					destination: ThemeView.init,
					label: EmptyView.init
				)
				
				TerciaryButtonView(
					label: {
						Text("OnBoarding.Skip".localized)
							.adaptiveFont(.latoRegular, size: 16)
						
					}
				) {
					viewStore.send(.alertButtonTapped)
				}
				.opacity(viewStore.isAppClip ? 0.0 : 1.0)
				.padding(.horizontal, 16)
				
				PrimaryButtonView(
					label: {
						Text("OnBoarding.Continue".localized)
							.adaptiveFont(.latoRegular, size: 16)
					}
				) {
					viewStore.send(.themeButtonTapped)
				}
				.padding(.horizontal, 16)
			}
			.padding()
			.navigationBarBackButtonHidden(true)
			.alert(
				store: self.store.scope(
					state: \.$alert,
					action: LayoutFeature.Action.alert
				)
			)
		}
	}
}
