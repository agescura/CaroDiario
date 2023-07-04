import AboutFeature
import AgreementsFeature
import AppearanceFeature
import CameraFeature
import ComposableArchitecture
import ExportFeature
import Foundation
import LanguageFeature
import LocalAuthenticationClient
import MicrophoneFeature
import Models
import PasscodeFeature
import StoreKitClient

public struct SettingsFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var authorizedVideoStatus: AuthorizedVideoStatus = .notDetermined
		@PresentationState public var destination: Destination.State?
		public var userSettings: UserSettings
		
		public init(
			userSettings: UserSettings
		) {
			self.userSettings = userSettings
		}
	}
	
	public enum Action: Equatable {
		case aboutButtonTapped
		case agreementsButtonTapped
		case appearanceButtonTapped
		case authorizedVideoStatusResponse(AuthorizedVideoStatus)
		case biometricResult(LocalAuthenticationType)
		case cameraButtonTapped
		case exportButtonTapped
		case destination(PresentationAction<Destination.Action>)
		case languageButtonTapped
		case microphoneButtonTapped
		case navigateToActivate
		case navigateToMenu
		case onAppear
		case reviewStoreKit
		case toggleShowSplash(isOn: Bool)
	}
	
	public struct Destination: ReducerProtocol {
		public init() {}
		
		public enum State: Equatable, Identifiable {
			case about(AboutFeature.State)
			case activate(ActivateFeature.State)
			case agreements(AgreementsFeature.State)
			case appearance(AppearanceFeature.State)
			case camera(CameraFeature.State)
			case export(ExportFeature.State)
			case language(LanguageFeature.State)
			case menu(MenuPasscodeFeature.State)
			case microphone(MicrophoneFeature.State)
			
			public var id: AnyHashable {
				switch self {
					case let .about(state):
						return state.id
					case let .activate(state):
						return state.id
					case let .agreements(state):
						return state.id
					case let .appearance(state):
						return state.id
					case let .camera(state):
						return state.id
					case let .export(state):
						return state.id
					case let .language(state):
						return state.id
					case let .menu(state):
						return state.id
					case let .microphone(state):
						return state.id
				}
			}
		}
		public enum Action: Equatable {
			case about(AboutFeature.Action)
			case activate(ActivateFeature.Action)
			case agreements(AgreementsFeature.Action)
			case appearance(AppearanceFeature.Action)
			case camera(CameraFeature.Action)
			case export(ExportFeature.Action)
			case language(LanguageFeature.Action)
			case menu(MenuPasscodeFeature.Action)
			case microphone(MicrophoneFeature.Action)
		}
		public var body: some ReducerProtocolOf<Self> {
			Scope(state: /State.about, action: /Action.about) {
				AboutFeature()
			}
			Scope(state: /State.activate, action: /Action.activate) {
				ActivateFeature()
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
				MicrophoneFeature()
			}
		}
	}
	
	@Dependency(\.avCaptureDeviceClient) private var avCaptureDeviceClient
	@Dependency(\.localAuthenticationClient) private var localAuthenticationClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.storeKitClient) private var storeKitClient
	@Dependency(\.userDefaultsClient) private var userDefaultsClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .aboutButtonTapped:
					state.destination = .about(AboutFeature.State())
					return .none

				case .agreementsButtonTapped:
					state.destination = .agreements(AgreementsFeature.State())
					return .none

				case .appearanceButtonTapped:
					state.destination = .appearance(
						AppearanceFeature.State(
							appearanceSettings: state.userSettings.appearance
						)
					)
					return .none

				case let .authorizedVideoStatusResponse(status):
					state.authorizedVideoStatus = status
					return .none

				case let .biometricResult(result):
					//				state.userSettings.authenticationType = result
					return .none

				case .cameraButtonTapped:
					state.destination = .camera(
						CameraFeature.State(cameraStatus: state.authorizedVideoStatus)
					)
					return .none
					
				case let .destination(.presented(action)):
					switch action {
						case .activate(.insert(.presented(.popToRoot))),
								.activate(.insert(.presented(.success))):
							return .send(.destination(.dismiss))
							
						case .activate:
							return .none
							
						case let .appearance(.destination(.presented(.style(.styleChanged(style))))):
							state.userSettings.appearance.styleType = style
							return .none
							
						case let .appearance(.destination(.presented(.layout(.layoutChanged(layout))))):
							state.userSettings.appearance.layoutType = layout
							return .none
							
						case let .appearance(.destination(.presented(.iconApp(.iconAppChanged(iconApp))))):
							state.userSettings.appearance.iconAppType = iconApp
							return .none
							
						case let .appearance(.destination(.presented(.theme(.themeChanged(theme))))):
							state.userSettings.appearance.themeType = theme
							return .none
							
						default:
							return .none
					}

				case .destination:
					return .none
					
				case .exportButtonTapped:
					state.destination = .export(
						ExportFeature.State()
					)
					return .none
					
				case .languageButtonTapped:
					state.destination = .language(
						LanguageFeature.State(language: state.userSettings.language)
					)
					return .none
					
				case .microphoneButtonTapped:
					//				state.destination = .microphone(
					//					.init(microphoneStatus: state.userSettings.microphoneStatus)
					//				)
					return .none

				case .navigateToActivate:
					state.destination = .activate(
						ActivateFeature.State(
							faceIdEnabled: state.userSettings.faceIdEnabled,
							hasPasscode: state.userSettings.passcode.count > 0
						)
					)
					return .none
					
				case .navigateToMenu:
	//				state.destination = .menu(
	//					.init(
	//						authenticationType: state.userSettings.authenticationType,
	//						optionTimeForAskPasscode: state.userSettings.optionTimeForAskPasscode,
	//						faceIdEnabled: state.userSettings.faceIdEnabled
	//					)
	//				)
					return .none
					
					
				case .onAppear:
					state.userSettings = self.userDefaultsClient.userSettings
					return .run { send in
						await send(.authorizedVideoStatusResponse(self.avCaptureDeviceClient.authorizationStatus()))
						await send(.biometricResult(self.localAuthenticationClient.determineType()))
					}
					
				case .reviewStoreKit:
					return .fireAndForget { await self.storeKitClient.requestReview() }
					
				case let .toggleShowSplash(isOn):
					state.userSettings.showSplash = isOn
					return .none
					
					//			case .activate(.insert(.presented(.navigateToMenu))):
					//				state.hasPasscode = true
					//				return .none
					//
					//			case let .menu(.delegate(delegate)),
					//				let .activate(.insert(.presented(.menu(.presented(.delegate(delegate)))))):
					//				switch delegate {
					//					case .turnOffPasscode:
					//						state.hasPasscode = false
					//						return EffectTask(value: .destination(.dismiss))
					//							.delay(for: 0.1, scheduler: self.mainQueue)
					//							.eraseToEffect()
					//					case .popToRoot:
					//						return EffectTask(value: .destination(.dismiss))
					//				}
					//
			}
		}
		.ifLet(\.$destination, action: /Action.destination) {
			Destination()
		}
		.onChange(of: \.userSettings) { userSettings, _, _ in
			.run { _ in
				await self.userDefaultsClient.set(userSettings)
			}
		}
	}
}
