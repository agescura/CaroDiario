import SwiftUI
import ComposableArchitecture
import Views
import SwiftUIHelper
import Localizables

public struct ActivateView: View {
	let store: StoreOf<ActivateFeature>
	
	public init(
		store: StoreOf<ActivateFeature>
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
				self.store.send(.insertButtonTapped)
			}
		}
		.padding(.horizontal, 16)
	}
}
