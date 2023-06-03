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
		
		public var destination2: Destination2? = nil {
			didSet {
				if case let .menu(state) = self.destination2 {
					self.faceIdEnabled = state.faceIdEnabled
				}
				if case let .activate(state) = self.destination2 {
					self.faceIdEnabled = state.faceIdEnabled
					self.hasPasscode = state.hasPasscode
				}
				if case let .camera(state) = self.destination2 {
					self.cameraStatus = state.cameraStatus
				}
				if case let .microphone(state) = self.destination2 {
					self.microphoneStatus = state.microphoneStatus
				}
			}
		}
		public enum Destination2: Equatable {
			case activate(ActivateFeature.State)
			case menu(MenuPasscodeFeature.State)
			case camera(Camera.State)
			case microphone(Microphone.State)
			case export(Export.State)
			case about(AboutFeature.State)
		}
		
		var activate: ActivateFeature.State? {
			get {
				guard case let .activate(state) = self.destination2 else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.destination2 = .activate(newValue)
			}
		}
		var menu: MenuPasscodeFeature.State? {
			get {
				guard case let .menu(state) = self.destination2 else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.destination2 = .menu(newValue)
			}
		}
		var camera: Camera.State? {
			get {
				guard case let .camera(state) = self.destination2 else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.destination2 = .camera(newValue)
			}
		}
		var microphone: Microphone.State? {
			get {
				guard case let .microphone(state) = self.destination2 else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.destination2 = .microphone(newValue)
			}
		}
		var export: Export.State? {
			get {
				guard case let .export(state) = self.destination2 else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.destination2 = .export(newValue)
			}
		}
		var about: AboutFeature.State? {
			get {
				guard case let .about(state) = self.destination2 else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.destination2 = .about(newValue)
			}
		}
		
		public init(
			showSplash: Bool = false,
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
			route: Destination2? = nil
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
			self.destination2 = route
		}
	}
	
	public enum Action: Equatable {
		case agreementsButtonTapped
		case appearanceButtonTapped
		case destination(PresentationAction<Destination.Action>)
		case languageButtonTapped
		case onAppear
		
		case toggleShowSplash(isOn: Bool)
		case biometricResult(LocalAuthenticationType)
		
		case navigateToActivate
		
		case menu(MenuPasscodeFeature.Action)
		case navigateMenu(Bool)
		
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
	
	public struct Destination: ReducerProtocol {
		public init() {}
		
		public enum State: Equatable, Identifiable {
			case activate(ActivateFeature.State)
			case agreements(AgreementsFeature.State)
			case appearance(AppearanceFeature.State)
			case language(LanguageFeature.State)
			
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
				}
			}
		}
		public enum Action: Equatable {
			case activate(ActivateFeature.Action)
			case agreements(AgreementsFeature.Action)
			case appearance(AppearanceFeature.Action)
			case language(LanguageFeature.Action)
		}
		public var body: some ReducerProtocolOf<Self> {
			Scope(state: /State.activate, action: /Action.activate) {
				ActivateFeature()
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
		}
	}
	
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.localAuthenticationClient) private var localAuthenticationClient
	@Dependency(\.storeKitClient) private var storeKitClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce(self.core)
			.ifLet(\.$destination, action: /Action.destination) {
				Destination()
			}
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
			.ifLet(\.menu, action: /Action.menu) {
				MenuPasscodeFeature()
			}
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> EffectTask<Action> {
		switch action {
			case .agreementsButtonTapped:
				state.destination = .agreements(AgreementsFeature.State())
				return .none
				
			case .appearanceButtonTapped:
				state.destination = .appearance(
					AppearanceFeature.State(
						styleType: state.styleType,
						layoutType: state.layoutType,
						themeType: state.themeType,
						iconAppType: state.iconAppType
					)
				)
				return .none
				
			case let .destination(.presented(action)):
				switch action {
					case .activate(.insert(.presented(.popToRoot))),
							.activate(.insert(.presented(.success))):
						return .send(.destination(.dismiss))
						
					case .activate:
						return .none
						
					default:
						return .none
				}
				
			case .destination(.dismiss):
				switch state.destination {
					case .activate:
						return .none
					case .agreements:
						return .none
					case .appearance:
						return .none
					case let .language(languageState):
						state.language = languageState.language
						return .none
					case .none:
						return .none
				}
				
			case .destination:
				return .none
				
			case .languageButtonTapped:
				state.destination = .language(
					LanguageFeature.State(language: state.language)
				)
				return .none
				
			case .onAppear:
				return .run { send in
					await send(.biometricResult(self.localAuthenticationClient.determineType()))
				}
				
			case let .toggleShowSplash(isOn):
				state.showSplash = isOn
				return .none
				
			case let .biometricResult(result):
				state.authenticationType = result
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
				
			case .navigateToActivate:
				state.destination = .activate(
					ActivateFeature.State(
						faceIdEnabled: state.faceIdEnabled,
						hasPasscode: state.hasPasscode
					)
				)
				return .none
				
			case .menu:
				return .none
				
			case let .navigateMenu(value):
				state.destination2 = value ? .menu(
					.init(
						authenticationType: state.authenticationType,
						optionTimeForAskPasscode: state.optionTimeForAskPasscode,
						faceIdEnabled: state.faceIdEnabled
					)
				) : nil
				return .none
				
			case .microphone:
				return .none
				
			case let .navigateMicrophone(value):
				state.destination2 = value ? .microphone(
					.init(microphoneStatus: state.microphoneStatus)
				) : nil
				return .none
				
			case .camera:
				return .none
				
			case let .navigateCamera(value):
				state.destination2 = value ? .camera(
					.init(cameraStatus: state.cameraStatus)
				) : nil
				return .none
				
			case .reviewStoreKit:
				return .fireAndForget { await self.storeKitClient.requestReview() }
				
			case let .navigateExport(value):
				state.destination2 = value ? .export(.init()) : nil
				return .none
				
			case .export:
				return .none
				
			case let .navigateAbout(value):
				state.destination2 = value ? .about(.init()) : nil
				return .none
				
			case .about:
				return .none
		}
	}
}
