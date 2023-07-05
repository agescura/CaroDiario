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

public struct Settings: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
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
		
		@PresentationState public var appearanceFeature: AppearanceFeature.State?
		
		public var route: Route? = nil {
			didSet {
				if case let .language(state) = self.route {
					self.language = state.language
				}
				if case let .menu(state) = self.route {
					self.faceIdEnabled = state.faceIdEnabled
				}
				if case let .activate(state) = self.route {
					self.faceIdEnabled = state.faceIdEnabled
					self.hasPasscode = state.hasPasscode
				}
				if case let .camera(state) = self.route {
					self.cameraStatus = state.cameraStatus
				}
				if case let .microphone(state) = self.route {
					self.microphoneStatus = state.microphoneStatus
				}
			}
		}
		public enum Route: Equatable {
			case language(Language.State)
			case activate(Activate.State)
			case menu(Menu.State)
			case camera(Camera.State)
			case microphone(Microphone.State)
			case export(Export.State)
			case agreements(Agreements.State)
			case about(AboutFeature.State)
		}
		
		var languageState: Language.State? {
			get {
				guard case let .language(state) = self.route else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.route = .language(newValue)
			}
		}
		var activate: Activate.State? {
			get {
				guard case let .activate(state) = self.route else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.route = .activate(newValue)
			}
		}
		var menu: Menu.State? {
			get {
				guard case let .menu(state) = self.route else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.route = .menu(newValue)
			}
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
		var agreements: Agreements.State? {
			get {
				guard case let .agreements(state) = self.route else { return nil }
				return state
			}
			set {
				guard let newValue = newValue else { return }
				self.route = .agreements(newValue)
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
		
		case appearanceAction(PresentationAction<AppearanceFeature.Action>)
		case appearanceButtonTapped
		
		case toggleShowSplash(isOn: Bool)
		case biometricResult(LocalAuthenticationType)
		
		case language(Language.Action)
		case navigateLanguage(Bool)
		
		case activate(Activate.Action)
		case navigateActivate(Bool)
		
		case menu(Menu.Action)
		case navigateMenu(Bool)
		
		case camera(Camera.Action)
		case navigateCamera(Bool)
		
		case microphone(Microphone.Action)
		case navigateMicrophone(Bool)
		
		case agreements(Agreements.Action)
		case navigateAgreements(Bool)
		
		case reviewStoreKit
		
		case export(Export.Action)
		case navigateExport(Bool)
		
		case about(AboutFeature.Action)
		case navigateAbout(Bool)
	}
	
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.localAuthenticationClient) private var localAuthenticationClient
	@Dependency(\.storeKitClient) private var storeKitClient
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce(self.core)
			.ifLet(\.agreements, action: /Settings.Action.agreements) {
				Agreements()
			}
			.ifLet(\.camera, action: /Settings.Action.camera) {
				Camera()
			}
			.ifLet(\.about, action: /Settings.Action.about) {
				AboutFeature()
			}
			.ifLet(\.export, action: /Settings.Action.export) {
				Export()
			}
			.ifLet(\.languageState, action: /Settings.Action.language) {
				Language()
			}
			.ifLet(\.microphone, action: /Settings.Action.microphone) {
				Microphone()
			}
			.ifLet(\.activate, action: /Settings.Action.activate) {
				Activate()
			}
			.ifLet(\.menu, action: /Settings.Action.menu) {
				Menu()
			}
			.ifLet(\.$appearanceFeature, action: /Action.appearanceAction) {
				AppearanceFeature()
			}
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> EffectTask<Action> {
		switch action {
				
			case .onAppear:
				return self.localAuthenticationClient.determineType()
					.map(Settings.Action.biometricResult)
				
			case .appearanceButtonTapped:
				state.appearanceFeature = AppearanceFeature.State(
					appearanceSettings: AppearanceSettings(
						styleType: state.styleType,
						layoutType: state.layoutType,
						themeType: state.themeType,
						iconAppType: state.iconAppType
					)
				)
				return .none
				
			case .appearanceAction:
				return .none
				
			case let .navigateLanguage(value):
				state.route = value ? .language(
					.init(language: state.language)
				) : nil
				return .none
				
			case .language:
				return .none
				
			case let .toggleShowSplash(isOn):
				state.showSplash = isOn
				return .none
				
			case let .biometricResult(result):
				state.authenticationType = result
				return .none
				
			case .activate(.insert(.navigateMenu(true))):
				state.hasPasscode = true
				return .none
				
			case .menu(.actionSheetTurnoffTapped),
					.activate(.insert(.menu(.actionSheetTurnoffTapped))):
				state.hasPasscode = false
				return Effect(value: .navigateActivate(false))
					.delay(for: 0.1, scheduler: self.mainQueue)
					.eraseToEffect()
				
			case .activate(.insert(.menu(.popToRoot))),
					.activate(.insert(.popToRoot)),
					.menu(.popToRoot),
					.activate(.insert(.success)):
				return Effect(value: .navigateActivate(false))
				
			case .activate:
				return .none
				
			case let .navigateActivate(value):
				state.route = value ? .activate(
					.init(
						faceIdEnabled: state.faceIdEnabled,
						hasPasscode: state.hasPasscode
					)
				) : nil
				return .none
				
			case .menu:
				return .none
				
			case let .navigateMenu(value):
				state.route = value ? .menu(
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
				
			case let .navigateAgreements(value):
				state.route = value ? .agreements(.init()) : nil
				return .none
				
			case .agreements:
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
