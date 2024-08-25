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
		@Shared(.userSettings) public var userSettings: UserSettings = .defaultValue
		
		public init() {}
	}
	
	public enum Action: ViewAction, Equatable {
		case delegate(Delegate)
		case dialog(PresentationAction<Dialog>)
		case faceId(response: Bool)
		case optionTimeForAskPasscode(TimeForAskPasscode)
		case toggleFaceId(isOn: Bool)
		case view(View)
		
		@CasePathable
		public enum Delegate: Equatable {
			case popToRoot
		}
		@CasePathable
		public enum Dialog: Equatable {
			case turnOff
		}
		@CasePathable
		public enum View: Equatable {
			case popButtonTapped
			case turnOffButtonTapped
		}
	}
	
	@Dependency(\.localAuthenticationClient) var localAuthenticationClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .delegate:
					return .none
				case .dialog(.presented(.turnOff)):
					state.userSettings.passcode = nil
					state.userSettings.localAuthenticationType = .none
					state.userSettings.timeForAskPasscode = .never
					state.userSettings.faceIdEnabled = false
					state.dialog = nil
					return .run { send in
						await send(.delegate(.popToRoot))
					}
				case .dialog:
					return .none
				case let .faceId(response: response):
					state.userSettings.faceIdEnabled = response
					return .none
				case let .optionTimeForAskPasscode(newOption):
					state.userSettings.optionTimeForAskPasscode = newOption.value
					return .none
				case let .toggleFaceId(isOn: value):
					if !value {
						return .send(.faceId(response: value))
					}
					return .run { [localAuthenticationType = state.userSettings.localAuthenticationType] send in
						await send(.faceId(response: self.localAuthenticationClient.evaluate("Settings.Biometric.Test".localized(with: [localAuthenticationType.rawValue]))))
					}
				case let .view(viewAction):
					switch viewAction {
						case .popButtonTapped:
							return .send(.delegate(.popToRoot))
						case .turnOffButtonTapped:
							state.dialog = .turnOff(state.userSettings.localAuthenticationType)
							return .none
					}
			}
		}
	}
}

extension ConfirmationDialogState where Action == MenuFeature.Action.Dialog {
	public static func turnOff(_ type: LocalAuthenticationType) -> Self {
		ConfirmationDialogState {
			TextState("Passcode.Turnoff.Message".localized(with: [type.rawValue]))
		} actions: {
			ButtonState(role: .cancel, label: { TextState("Cancel".localized) })
			ButtonState(action: .turnOff, label: { TextState("Passcode.Turnoff".localized) })
		}
	}
}
