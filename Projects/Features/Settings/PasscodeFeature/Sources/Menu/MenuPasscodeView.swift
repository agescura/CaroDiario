import SwiftUI
import ComposableArchitecture
import Views
import Localizables
import SwiftUIHelper
import Models

@ViewAction(for: MenuFeature.self)
public struct MenuPasscodeView: View {
	@Bindable public var store: StoreOf<MenuFeature>
	
	public init(
		store: StoreOf<MenuFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		Form {
			Section(
				footer: Text("Passcode.Activate.Message".localized)
					.textStyle(.body)
			) {
				Button("Passcode.Turnoff".localized) {
					send(.turnOffButtonTapped)
				}
				.buttonStyle(.plain(.chambray))
			}
			
			Section {
				Toggle(
					isOn: $store.userSettings.faceIdEnabled.sending(\.toggleFaceId)
				) {
					Text("Passcode.UnlockFaceId".localized(with: [store.userSettings.localAuthenticationType.rawValue]))
						.textStyle(.body(.chambray))
				}
				.toggleStyle(SwitchToggleStyle(tint: .chambray))
				
				Picker(
					selection: $store.userSettings.timeForAskPasscode.sending(\.optionTimeForAskPasscode)
				) {
					ForEach(store.userSettings.listTimesForAskPasscode, id: \.self) { type in
						Text(type.rawValue)
					}
				} label: {
					Text("Passcode.Autolock".localized)
						.textStyle(.body(.chambray))
				}
			}
		}
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button(systemName: .chevronLeft) {
					send(.popButtonTapped)
				}
				.buttonStyle(.icon)
			}
		}
		.navigationBarTitle("Passcode.Title".localized)
		.navigationBarBackButtonHidden(true)
		.confirmationDialog(
			store: store.scope(
				state: \.$dialog,
				action: \.dialog
			)
		)
	}
}

#Preview {
	NavigationStack {
		MenuPasscodeView(
			store: Store(
				initialState: MenuFeature.State(),
				reducer: { MenuFeature() }
			)
		)
	}
}
