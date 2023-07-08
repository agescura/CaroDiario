import ComposableArchitecture
import Localizables
import SwiftUI
import SwiftUIHelper
import TCAHelpers
import Views

public struct ActivateView: View {
	private let store: StoreOf<ActivatePasscodeFeature>
	
	public init(
		store: StoreOf<ActivatePasscodeFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		VStack(spacing: 16) {
			Text("Passcode.Title".localized)
				.font(.title)
			Text("Passcode.Activate.Message".localized)
				.font(.caption)
			Spacer()
			
			PrimaryButtonView(
				label: { Text("Passcode.Activate.Title".localized) }
			) {
				store.send(.insertButtonTapped)
			}
			
			NavigationLinkStore(
				self.store.scope(
					state: \.$insert,
					action: ActivatePasscodeFeature.Action.insert
				),
				destination: InsertPasscodeView.init
			)
		}
		.padding(.horizontal, 16)
	}
}
