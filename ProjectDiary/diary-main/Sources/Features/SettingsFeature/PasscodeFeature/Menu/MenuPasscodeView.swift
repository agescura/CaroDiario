import ComposableArchitecture
import Localizables
import Models
import SwiftUI
import SwiftUIHelper
import Views

public struct MenuPasscodeView: View {
	private let store: StoreOf<MenuPasscodeFeature>
	
	private struct ViewState: Equatable {
		let authenticationType: LocalAuthenticationType
		let faceIdEnabled: Bool
		let listTimesForAskPasscode: [TimeForAskPasscode]
		let optionTimeForAskPasscode: TimeForAskPasscode
		
		init(
			state: MenuPasscodeFeature.State
		) {
			self.authenticationType = state.authenticationType
			self.faceIdEnabled = state.faceIdEnabled
			self.listTimesForAskPasscode = state.listTimesForAskPasscode
			self.optionTimeForAskPasscode = state.optionTimeForAskPasscode
		}
	}
	
	public init(
		store: StoreOf<MenuPasscodeFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: ViewState.init
		) { viewStore in
			Form {
				Section(
					footer: Text("Passcode.Activate.Message".localized)
				) {
					Button {
						viewStore.send(.confirmationDialogButtonTapped)
					} label: {
						Text("Passcode.Turnoff".localized)
							.foregroundColor(.chambray)
					}
				}
				
				Section {
					Toggle(
						isOn: viewStore.binding(
							get: \.faceIdEnabled,
							send: MenuPasscodeFeature.Action.toggleFaceId
						)
					) {
						Text("Passcode.UnlockFaceId".localized(with: [viewStore.authenticationType.rawValue]))
							.foregroundColor(.chambray)
					}
					.toggleStyle(SwitchToggleStyle(tint: .chambray))
					
					Picker(
						"",
						selection: viewStore.binding(
							get: \.optionTimeForAskPasscode,
							send: MenuPasscodeFeature.Action.optionTimeForAskPasscode
						)
					) {
						ForEach(viewStore.listTimesForAskPasscode, id: \.self) { type in
							Text(type.rawValue)
								.adaptiveFont(.latoRegular, size: 12)
						}
					}
					.overlay(
						HStack(spacing: 16) {
							Text("Passcode.Autolock".localized)
								.foregroundColor(.chambray)
								.adaptiveFont(.latoRegular, size: 12)
							Spacer()
						}
					)
				}
			}
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						viewStore.send(.popToRootButtonTapped)
					} label: {
						Image(.chevronLeft)
					}
				}
			}
			.confirmationDialog(
				store: self.store.scope(
					state: \.$confirmationDialog,
					action: MenuPasscodeFeature.Action.confirmationDialog
				)
			)
		}
		.navigationBarTitle("Passcode.Title".localized)
		.navigationBarBackButtonHidden(true)
	}
}
