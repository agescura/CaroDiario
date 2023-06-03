import SwiftUI
import ComposableArchitecture
import Views
import Localizables
import SwiftUIHelper

public struct AboutView: View {
	let store: StoreOf<AboutFeature>
	
	public init(
		store: StoreOf<AboutFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: { $0 }
		) { viewStore in
			VStack {
				Form {
					Section {
						HStack(spacing: 16) {
							Text("Settings.Version".localized)
								.foregroundColor(.chambray)
								.adaptiveFont(.latoRegular, size: 12)
							Spacer()
							Text("1.7")
								.foregroundColor(.adaptiveGray)
								.adaptiveFont(.latoRegular, size: 12)
						}
					}
					
					Section {
						HStack(spacing: 16) {
							
							Text("Settings.ReportBug".localized)
								.foregroundColor(.chambray)
								.adaptiveFont(.latoRegular, size: 12)
							Spacer()
							Image(.chevronRight)
								.foregroundColor(.adaptiveGray)
						}
						.contentShape(Rectangle())
						.onTapGesture {
							viewStore.send(.confirmationDialogButtonTapped)
						}
					}
				}
			}
			.confirmationDialog(
				store: self.store.scope(
					state: \.$dialog,
					action: AboutFeature.Action.dialog
				)
			)
		}
		.navigationBarTitle("Settings.About".localized)
	}
}
