import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import Models
import EntriesFeature
import Styles

public struct StyleView: View {
	private let store: StoreOf<StyleFeature>
	
	private struct ViewState: Equatable {
		let styleType: StyleType
		let isAppClip: Bool
		
		public init(
			state: StyleFeature.State
		) {
			self.styleType = state.styleType
			self.isAppClip = state.isAppClip
		}
	}
	
	public init(
		store: StoreOf<StyleFeature>
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
						
						Text("OnBoarding.Style.Title".localized)
							.adaptiveFont(.latoBold, size: 24)
							.foregroundColor(.adaptiveBlack)
						
						Text("OnBoarding.Style.Message".localized)
							.foregroundColor(.adaptiveGray)
							.adaptiveFont(.latoRegular, size: 10)
						
						Picker("",  selection: viewStore.binding(
							get: \.styleType,
							send: StyleFeature.Action.styleChanged
						)) {
							ForEach(StyleType.allCases, id: \.self) { type in
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
									action: StyleFeature.Action.entries(id:action:)),
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
						state: \.$layout,
						action: StyleFeature.Action.layout
					),
					destination: LayoutView.init,
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
					viewStore.send(.layoutButtonTapped)
				}
				.padding(.horizontal, 16)
			}
			.padding()
			.navigationBarBackButtonHidden(true)
			.alert(
				store: self.store.scope(
					state: \.$alert,
					action: StyleFeature.Action.alert
				)
			)
		}
	}
}

struct StyleView_Previews: PreviewProvider {
	static var previews: some View {
		StyleView(
			store: .init(
				initialState: StyleFeature.State(
					entries: fakeEntries(
						with: .rectangle,
						layout: .horizontal
					),
					layoutType: .horizontal,
					styleType: .rectangle
					
				),
				reducer: StyleFeature())
		)
	}
}
