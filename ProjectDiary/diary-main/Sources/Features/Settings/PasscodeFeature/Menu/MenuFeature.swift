import Foundation
import ComposableArchitecture
import LocalAuthenticationClient
import UserDefaultsClient
import Models
import SwiftUIHelper

extension TimeForAskPasscode: Identifiable {
	public var rawValue: String {
		switch self {
			case .always:
				return "Passcode.Always".localized
			case .never:
				return "Passcode.Disabled".localized
			case let .after(minutes: minutes):
				return "\("Passcode.IfAway".localized)\(minutes) min"
		}
	}
	
	public var id: String {
		rawValue
	}
}

@Reducer
public struct MenuFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		@Presents public var dialog: ConfirmationDialogState<Action.Dialog>?
		public var authenticationType: LocalAuthenticationType
		public var optionTimeForAskPasscode: TimeForAskPasscode
		public let listTimesForAskPasscode: [TimeForAskPasscode] = [
			.never,
			.always,
			.after(minutes: 1),
			.after(minutes: 5),
			.after(minutes: 30),
			.after(minutes: 60)
		]
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
		public init(
			authenticationType: LocalAuthenticationType,
			optionTimeForAskPasscode: Int
		) {
			self.authenticationType = authenticationType
			self.optionTimeForAskPasscode = TimeForAskPasscode(optionTimeForAskPasscode)
		}
	}
	
	public enum Action: Equatable {
		case dialog(PresentationAction<Dialog>)
		case popToRoot
		case actionSheetButtonTapped
		case toggleFaceId(isOn: Bool)
		case faceId(response: Bool)
		case optionTimeForAskPasscode(TimeForAskPasscode)
		
		public enum Dialog: Equatable {
			case turnOff
		}
	}
	
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.localAuthenticationClient) private var localAuthenticationClient
	
	public var body: some ReducerOf<Self> {
		Reduce(self.core)
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
			case .dialog:
				return .none
				
			case .popToRoot:
				return .none
				
			case .actionSheetButtonTapped:
				state.dialog = ConfirmationDialogState {
					TextState("Passcode.Turnoff.Message".localized(with: [state.authenticationType.rawValue]))
				} actions: {
					ButtonState(role: .cancel, label: { TextState("Cancel".localized) })
					ButtonState(action: .turnOff, label: { TextState("Passcode.Turnoff".localized) })
				}
				return .none
				
			case let .toggleFaceId(isOn: value):
				if !value {
					return .send(.faceId(response: value))
				}
				return .run { [state] send in
					await send(.faceId(response: self.localAuthenticationClient.evaluate("Settings.Biometric.Test".localized(with: [state.authenticationType.rawValue]))))
				}
				
			case let .faceId(response: response):
				state.userSettings.faceIdEnabled = response
				return .none
				
			case let .optionTimeForAskPasscode(newOption):
				state.optionTimeForAskPasscode = newOption
				return .none
		}
	}
}
