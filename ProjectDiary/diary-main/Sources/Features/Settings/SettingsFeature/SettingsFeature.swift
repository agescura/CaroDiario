import Foundation
import ComposableArchitecture
import MicrophoneFeature
import AboutFeature
import AgreementsFeature
import AppearanceFeature
import CameraFeature
import ExportFeature
import LanguageFeature
import PasscodeFeature
import Models
import StoreKitClient
import LocalAuthenticationClient

public struct SettingsFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var destination: Destination.State?
		
		public var showSplash: Bool
		
		public var styleType: StyleType
		public var layoutType: LayoutType
		public var themeType: ThemeType
		public var iconAppType: IconAppType
		public var language: Localizable
		
		public var authenticationType: LocalAuthenticationType = .none
		public var hasPasscode: Bool
		
		public var cameraStatus: AuthorizedVideoStatus
		public var microphoneStatus: AudioRecordPermission
		public var optionTimeForAskPasscode: Int
		public var faceIdEnabled: Bool
		
		public init(
			cameraStatus: AuthorizedVideoStatus,
			destination: Destination.State? = nil,
			microphoneStatus: AudioRecordPermission,
			userSettings: UserSettings
		) {
			self.destination = destination
			self.showSplash = userSettings.showSplash
			self.styleType = userSettings.appearance.styleType
			self.layoutType = userSettings.appearance.layoutType
			self.themeType = userSettings.appearance.themeType
			self.hasPasscode = userSettings.hasPasscode
			self.iconAppType = userSettings.appearance.iconAppType
			self.cameraStatus = cameraStatus
			self.optionTimeForAskPasscode = userSettings.optionTimeForAskPasscode
			self.faceIdEnabled = userSettings.faceIdEnabled
			self.language = userSettings.language
			self.microphoneStatus = microphoneStatus
		}
	}
	
	public enum Action: Equatable {
		case onAppear
		case destination(PresentationAction<Destination.Action>)
		case appearanceButtonTapped
		
		case toggleShowSplash(isOn: Bool)
		case biometricResult(LocalAuthenticationType)
		
		case languageButtonTapped
		case agreementsButtonTapped
		case menuButtonTapped
		case activateButtonTapped
		case cameraButtonTapped
		case microphoneButtonTapped
		case aboutButtonTapped
		case reviewStoreKit
		case exportButtonTapped
	}
	
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.localAuthenticationClient) private var localAuthenticationClient
	@Dependency(\.storeKitClient) private var storeKitClient
	
	public struct Destination: ReducerProtocol {
		public enum State: Equatable {
			case about(AboutFeature.State)
			case activate(ActivatePasscodeFeature.State)
			case agreements(AgreementsFeature.State)
			case appearance(AppearanceFeature.State)
			case camera(CameraFeature.State)
			case export(ExportFeature.State)
			case language(LanguageFeature.State)
			case menu(MenuPasscodeFeature.State)
			case microphone(Microphone.State)
		}
		
		public enum Action: Equatable {
			case about(AboutFeature.Action)
			case activate(ActivatePasscodeFeature.Action)
			case agreements(AgreementsFeature.Action)
			case appearance(AppearanceFeature.Action)
			case camera(CameraFeature.Action)
			case export(ExportFeature.Action)
			case language(LanguageFeature.Action)
			case menu(MenuPasscodeFeature.Action)
			case microphone(Microphone.Action)
		}
		
		public var body: some ReducerProtocolOf<Self> {
			Scope(state: /State.about, action: /Action.about) {
				AboutFeature()
			}
			Scope(state: /State.activate, action: /Action.activate) {
				ActivatePasscodeFeature()
			}
			Scope(state: /State.agreements, action: /Action.agreements) {
				AgreementsFeature()
			}
			Scope(state: /State.appearance, action: /Action.appearance) {
				AppearanceFeature()
			}
			Scope(state: /State.camera, action: /Action.camera) {
				CameraFeature()
			}
			Scope(state: /State.export, action: /Action.export) {
				ExportFeature()
			}
			Scope(state: /State.language, action: /Action.language) {
				LanguageFeature()
			}
			Scope(state: /State.menu, action: /Action.menu) {
				MenuPasscodeFeature()
			}
			Scope(state: /State.microphone, action: /Action.microphone) {
				Microphone()
			}
		}
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce(self.core)
			.ifLet(\.$destination, action: /Action.destination) {
				Destination()
			}
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> EffectTask<Action> {
		switch action {
			case .onAppear:
				return .run { send in
					await send(.biometricResult(self.localAuthenticationClient.determineType()))
				}
				
			case .appearanceButtonTapped:
				state.destination = .appearance(
					AppearanceFeature.State(
						appearanceSettings: AppearanceSettings(
							styleType: state.styleType,
							layoutType: state.layoutType,
							themeType: state.themeType,
							iconAppType: state.iconAppType
						)
					)
				)
				return .none
				
			case .languageButtonTapped:
				state.destination = .language(
					LanguageFeature.State(language: state.language)
				)
				return .none
				
			case let .toggleShowSplash(isOn):
				state.showSplash = isOn
				return .none
				
			case let .biometricResult(result):
				state.authenticationType = result
				return .none
				
			case.destination(.presented(.activate(.insert(.presented(.menuButtonTapped))))):
				state.hasPasscode = true
				return .none
				
			case .destination(.presented(.menu(.delegate(.turnOffPasscode)))),
					.destination(.presented(.activate(.insert(.presented(.menu(.presented(.delegate(.turnOffPasscode)))))))):
				state.hasPasscode = false
				state.destination = nil
				return .none
			
			case .destination(.presented(.activate(.insert(.presented(.menu(.presented(.delegate(.popToRoot)))))))),
					.destination(.presented(.activate(.insert(.presented(.delegate(.popToRoot)))))),
					.destination(.presented(.menu(.delegate(.popToRoot)))),
					.destination(.presented(.activate(.insert(.presented(.delegate(.success)))))):
				state.destination = nil
				return .none
				
			case .destination(.dismiss):
				switch state.destination {
					case let .camera(cameraState):
						state.cameraStatus = cameraState.cameraStatus
					case let .microphone(microphoneState):
						state.microphoneStatus = microphoneState.microphoneStatus
					case .about, .activate, .agreements, .appearance, .export, .language, .menu, .none:
						break
				}
				return .none
				
			case .destination:
				return .none
				
			case .activateButtonTapped:
				state.destination = .activate(
					ActivatePasscodeFeature.State(
						faceIdEnabled: state.faceIdEnabled,
						hasPasscode: state.hasPasscode
					)
				)
				return .none
				
			case .menuButtonTapped:
				state.destination = .menu(
					MenuPasscodeFeature.State(
						authenticationType: state.authenticationType,
						optionTimeForAskPasscode: state.optionTimeForAskPasscode,
						faceIdEnabled: state.faceIdEnabled
					)
				)
				return .none
				
			case .microphoneButtonTapped:
				state.destination = .microphone(
					Microphone.State(microphoneStatus: state.microphoneStatus)
				)
				return .none
				
			case .cameraButtonTapped:
				state.destination = .camera(
					CameraFeature.State(cameraStatus: state.cameraStatus)
				)
				return .none
				
			case .agreementsButtonTapped:
				state.destination = .agreements(
					AgreementsFeature.State()
				)
				return .none
				
			case .reviewStoreKit:
				self.storeKitClient.requestReview()
				return .none
				
			case .exportButtonTapped:
				state.destination = .export(
					ExportFeature.State()
				)
				return .none
				
			case .aboutButtonTapped:
				state.destination = .about(
					AboutFeature.State()
				)
				return .none
		}
	}
}
