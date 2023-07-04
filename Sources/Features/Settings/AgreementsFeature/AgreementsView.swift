import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import SwiftUIHelper

public struct AgreementsView: View {
	let store: StoreOf<AgreementsFeature>
	
	public init(
		store: StoreOf<AgreementsFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store.stateless
		) { viewStore in
			Form {
				Section {
					HStack(spacing: 16) {
						IconImageView(
							.squareAndArrowUp,
							foregroundColor: .green
						)
						Text(AgreementType.composableArchitecture.title)
							.foregroundColor(.chambray)
							.adaptiveFont(.latoRegular, size: 12)
							.minimumScaleFactor(0.01)
							.lineLimit(1)
						Spacer()
						Image(.chevronRight)
							.foregroundColor(.adaptiveGray)
					}
					.contentShape(Rectangle())
					.onTapGesture {
						viewStore.send(.open(.composableArchitecture))
					}
				}
				Section {
					HStack(spacing: 16) {
						IconImageView(
							.exclamationMarkCircle,
							foregroundColor: .yellow
						)
						Text(AgreementType.pointfree.title)
							.foregroundColor(.chambray)
							.adaptiveFont(.latoRegular, size: 12)
							.minimumScaleFactor(0.01)
							.lineLimit(1)
						Spacer()
						Image(.chevronRight)
							.foregroundColor(.adaptiveGray)
					}
					.contentShape(Rectangle())
					.onTapGesture {
						viewStore.send(.open(.pointfree))
					}
					HStack(spacing: 16) {
						IconImageView(
							.exclamationMarkCircle,
							foregroundColor: .yellow
						)
						Text(AgreementType.raywenderlich.title)
							.foregroundColor(.chambray)
							.adaptiveFont(.latoRegular, size: 12)
						Spacer()
						Image(.chevronRight)
							.foregroundColor(.adaptiveGray)
					}
					.contentShape(Rectangle())
					.onTapGesture {
						viewStore.send(.open(.raywenderlich))
					}
				}
			}
			.navigationBarTitle("Settings.Agreements".localized)
		}
	}
}

struct AgreementsView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			AgreementsView(
				store: Store(
					initialState: AgreementsFeature.State(),
					reducer: AgreementsFeature()
				)
			)
		}
	}
}
