import ComposableArchitecture
import Localizables
import Styles
import SwiftUI
import SwiftUIHelper
import Views

@ViewAction(for: ActivateFeature.self)
public struct ActivateView: View {
	public let store: StoreOf<ActivateFeature>
	
	public init(
		store: StoreOf<ActivateFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		VStack(spacing: 16) {
			Text("Passcode.Title".localized)
				.textStyle(.title)
			Text("Passcode.Activate.Message".localized)
				.textStyle(.body)
			Spacer()
			
			Button("Passcode.Activate.Title".localized) {
				send(.insertButtonTapped)
			}
			.buttonStyle(.primary)
		}
		.padding(.horizontal, 16)
		.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	ActivateView(
		store: Store(
			initialState: ActivateFeature.State(),
			reducer: { ActivateFeature() }
		)
	)
}
