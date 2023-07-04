import SwiftUI
import ComposableArchitecture
import Views
import Localizables
import SwiftUIHelper
import Models

public struct MenuPasscodeView: View {
	let store: StoreOf<MenuPasscodeFeature>
	
	private struct ViewState: Equatable {
		let faceIdEnabled: Bool
		let authenticationType: LocalAuthenticationType
		let optionTimeForAskPasscode: TimeForAskPasscode
		let listTimesForAskPasscode: [TimeForAskPasscode]
		
		init(
			state: MenuPasscodeFeature.State
		) {
			self.faceIdEnabled = state.faceIdEnabled
			self.authenticationType = state.authenticationType
			self.optionTimeForAskPasscode = state.optionTimeForAskPasscode
			self.listTimesForAskPasscode = state.listTimesForAskPasscode
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
					Button(action: {
						viewStore.send(.confirmationDialogButtonTapped)
					}) {
						Text("Passcode.Turnoff".localized)
							.foregroundColor(.chambray)
					}
					.confirmationDialog(
						store: self.store.scope(
							state: \.$confirmationDialog,
							action: MenuPasscodeFeature.Action.confirmationDialog
						)
					)
				}
				
				Section(header: Text(""), footer: Text("")) {
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
					
					Picker("",  selection: viewStore.binding(
						get: \.optionTimeForAskPasscode,
						send: MenuPasscodeFeature.Action.optionTimeForAskPasscode
					)) {
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
		}
		.navigationBarTitle("Passcode.Title".localized)
		.navigationBarBackButtonHidden(true)
	}
}

struct MenuPasscodeView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			MenuPasscodeView(
				store: Store(
					initialState: MenuPasscodeFeature.State(
						authenticationType: .none,
						optionTimeForAskPasscode: 0,
						faceIdEnabled: false
					),
					reducer: MenuPasscodeFeature()
				)
			)
		}
		.previewDisplayName("Default")
		
		NavigationView {
			MenuPasscodeView(
				store: Store(
					initialState: MenuPasscodeFeature.State(
						authenticationType: .touchId,
						optionTimeForAskPasscode: 0,
						faceIdEnabled: true
					),
					reducer: MenuPasscodeFeature()
				)
			)
		}
		.previewDisplayName("Unlock")
		
		NavigationView {
			MenuPasscodeView(
				store: Store(
					initialState: MenuPasscodeFeature.State(
						authenticationType: .faceId,
						optionTimeForAskPasscode: 30,
						faceIdEnabled: true
					),
					reducer: MenuPasscodeFeature()
				)
			)
		}
		.previewDisplayName("Autolock")
	}
}
