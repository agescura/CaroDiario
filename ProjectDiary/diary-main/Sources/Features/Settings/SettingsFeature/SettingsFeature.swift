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
		
		public var route: Route? = nil {
			didSet {
//				if case let .menu(state) = self.route {
//					self.faceIdEnabled = state.faceIdEnabled
//				}
//				if case let .activate(state) = self.route {
//					self.faceIdEnabled = state.faceIdEnabled
//					self.hasPasscode = state.hasPasscode
//				}
				if case let .camera(state) = self.route {
					self.cameraStatus = state.cameraStatus
				}
				if case let .microphone(state) = self.route {
					self.microphoneStatus = state.microphoneStatus
				}
			}
		}
		public enum Route: Equatable {
			case camera(Camera.State)
			case microphone(Microphone.State)
			case export(Export.State)
			case about(AboutFeature.State)
		}
		
		var camera: Camera.State? {
			get {
				guard case let .camera(state) = self.route else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.route = .camera(newValue)
			}
		}
		var microphone: Microphone.State? {
			get {
				guard case let .microphone(state) = self.route else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.route = .microphone(newValue)
			}
		}
		var export: Export.State? {
			get {
				guard case let .export(state) = self.route else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.route = .export(newValue)
			}
		}
		var about: AboutFeature.State? {
			get {
				guard case let .about(state) = self.route else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.route = .about(newValue)
			}
		}
		
		public init(
			showSplash: Bool,
			styleType: StyleType,
			layoutType: LayoutType,
			themeType: ThemeType,
			iconType: IconAppType,
			hasPasscode: Bool,
			cameraStatus: AuthorizedVideoStatus,
			optionTimeForAskPasscode: Int,
			faceIdEnabled: Bool,
			language: Localizable,
			microphoneStatus: AudioRecordPermission,
			route: Route? = nil
		) {
			self.showSplash = showSplash
			self.styleType = styleType
			self.layoutType = layoutType
			self.themeType = themeType
			self.hasPasscode = hasPasscode
			self.iconAppType = iconType
			self.cameraStatus = cameraStatus
			self.optionTimeForAskPasscode = optionTimeForAskPasscode
			self.faceIdEnabled = faceIdEnabled
			self.language = language
			self.microphoneStatus = microphoneStatus
			self.route = route
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
		
		case camera(Camera.Action)
		case navigateCamera(Bool)
		
		case microphone(Microphone.Action)
		case navigateMicrophone(Bool)
		
		case reviewStoreKit
		
		case export(Export.Action)
		case navigateExport(Bool)
		
		case about(AboutFeature.Action)
		case navigateAbout(Bool)
	}
	
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.localAuthenticationClient) private var localAuthenticationClient
	@Dependency(\.storeKitClient) private var storeKitClient
	
	public struct Destination: ReducerProtocol {
		public init() {}
		
		public enum State: Equatable, Identifiable {
			case activate(ActivatePasscodeFeature.State)
			case agreements(AgreementsFeature.State)
			case appearance(AppearanceFeature.State)
			case language(LanguageFeature.State)
			case menu(MenuPasscodeFeature.State)
			public var id: AnyHashable {
				switch self {
					case let .activate(state):
						return state.id
					case let .agreements(state):
						return state.id
					case let .appearance(state):
						return state.id
					case let .language(state):
						return state.id
					case let .menu(state):
						return state.id
				}
			}
		}
		public enum Action: Equatable {
			case activate(ActivatePasscodeFeature.Action)
			case agreements(AgreementsFeature.Action)
			case appearance(AppearanceFeature.Action)
			case language(LanguageFeature.Action)
			case menu(MenuPasscodeFeature.Action)
		}
		public var body: some ReducerProtocolOf<Self> {
			Scope(state: /State.activate, action: /Action.activate) {
				ActivatePasscodeFeature()
			}
			Scope(state: /State.agreements, action: /Action.agreements) {
				AgreementsFeature()
			}
			Scope(state: /State.appearance, action: /Action.appearance) {
				AppearanceFeature()
			}
			Scope(state: /State.language, action: /Action.language) {
				LanguageFeature()
			}
			Scope(state: /State.menu, action: /Action.menu) {
				MenuPasscodeFeature()
			}
		}
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce(self.core)
			.ifLet(\.camera, action: /Action.camera) {
				Camera()
			}
			.ifLet(\.about, action: /Action.about) {
				AboutFeature()
			}
			.ifLet(\.export, action: /Action.export) {
				Export()
			}
			.ifLet(\.microphone, action: /Action.microphone) {
				Microphone()
			}
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
				
			case .microphone:
				return .none
				
			case let .navigateMicrophone(value):
				state.route = value ? .microphone(
					.init(microphoneStatus: state.microphoneStatus)
				) : nil
				return .none
				
			case .camera:
				return .none
				
			case let .navigateCamera(value):
				state.route = value ? .camera(
					.init(cameraStatus: state.cameraStatus)
				) : nil
				return .none
				
			case .agreementsButtonTapped:
				state.destination = .agreements(
					AgreementsFeature.State()
				)
				return .none
				
			case .reviewStoreKit:
				return self.storeKitClient.requestReview()
					.fireAndForget()
				
			case let .navigateExport(value):
				state.route = value ? .export(.init()) : nil
				return .none
				
			case .export:
				return .none
				
			case let .navigateAbout(value):
				state.route = value ? .about(.init()) : nil
				return .none
				
			case .about:
				return .none
		}
	}
}
