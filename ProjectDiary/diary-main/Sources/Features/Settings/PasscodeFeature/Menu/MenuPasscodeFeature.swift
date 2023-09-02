import ComposableArchitecture
import Foundation
import LocalAuthenticationClient
import Models
import SwiftUIHelper
import UserDefaultsClient

public enum TimeForAskPasscode: Equatable, Identifiable, Hashable {
	case always
	case never
	case after(minutes: Int)
}

extension TimeForAskPasscode {
	init(_ value: Int) {
		if value == -1 {
			self = .always
		} else if value > 0 {
			self = .after(minutes: value)
		} else {
			self = .never
		}
	}
}

extension TimeForAskPasscode {
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
	
	public var value: Int {
		switch self {
			case .always:
				return -1
			case .never:
				return -2
			case let .after(minutes: minutes):
				return minutes
		}
	}
}

public struct MenuPasscodeFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState var confirmationDialog: ConfirmationDialogState<Action.Dialog>?
		public var authenticationType: LocalAuthenticationType
		public var faceIdEnabled: Bool
		public var optionTimeForAskPasscode: TimeForAskPasscode
		public let listTimesForAskPasscode: [TimeForAskPasscode] = [
			.never,
			.always,
			.after(minutes: 1),
			.after(minutes: 5),
			.after(minutes: 30),
			.after(minutes: 60)
		]
		
		public init(
			authenticationType: LocalAuthenticationType,
			optionTimeForAskPasscode: Int,
			faceIdEnabled: Bool
		) {
			self.authenticationType = authenticationType
			self.optionTimeForAskPasscode = TimeForAskPasscode(optionTimeForAskPasscode)
			self.faceIdEnabled = faceIdEnabled
		}
	}
	
	public enum Action: Equatable {
		case confirmationDialogButtonTapped
		case confirmationDialog(PresentationAction<Dialog>)
		case delegate(Delegate)
		case faceId(response: Bool)
		case optionTimeForAskPasscode(changed: TimeForAskPasscode)
		case popToRootButtonTapped
		case toggleFaceId(isOn: Bool)
		
		public enum Dialog: Equatable {
			case turnOffButtonTapped
		}
		
		public enum Delegate: Equatable {
			case turnOffPasscode
			case popToRoot
		}
	}
	
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.localAuthenticationClient) private var localAuthenticationClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .confirmationDialogButtonTapped:
					state.confirmationDialog = .confirmationDialog(type: state.authenticationType)
					return .none
					
				case .confirmationDialog(.presented(.turnOffButtonTapped)):
					return .run { send in
						await send(.delegate(.turnOffPasscode))
					}
					
				case .confirmationDialog:
					return .none
					
				case .delegate:
					return .none
					
				case let .faceId(response: response):
					state.faceIdEnabled = response
					return .none
					
				case let .optionTimeForAskPasscode(changed: newOption):
					state.optionTimeForAskPasscode = newOption
					return .none
					
				case .popToRootButtonTapped:
					return .send(.delegate(.popToRoot))
					
				case let .toggleFaceId(isOn: value):
					if !value {
						return .send(.faceId(response: value))
					}
					return .run { [type = state.authenticationType] send in
						await send(.faceId(response: self.localAuthenticationClient.evaluate("Settings.Biometric.Test".localized(with: [type.rawValue]))))
					}
			}
		}
		.ifLet(\.$confirmationDialog, action: /Action.confirmationDialog)
	}
}

extension ConfirmationDialogState where Action == MenuPasscodeFeature.Action.Dialog {
	static func confirmationDialog(type: LocalAuthenticationType) -> Self {
		ConfirmationDialogState {
			TextState("Passcode.Turnoff.Message".localized(with: [type.rawValue]))
		} actions: {
			ButtonState(role: .cancel) {
				TextState("Cancel".localized)
			}
			ButtonState(action: .turnOffButtonTapped) {
				TextState("Passcode.Turnoff".localized)
			}
		} message: {
			TextState("Are you sure you want to delete this item?")
		}
	}
}
