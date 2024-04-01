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
    
    public var destination: Destination? = nil {
      didSet {
        if case let .appearance(state) = self.destination {
          self.styleType = state.styleType
          self.layoutType = state.layoutType
          self.themeType = state.themeType
          self.iconAppType = state.iconAppType
        }
        if case let .language(state) = self.destination {
          self.language = state.language
        }
        if case let .menu(state) = self.destination {
          self.faceIdEnabled = state.faceIdEnabled
        }
        if case let .activate(state) = self.destination {
          self.faceIdEnabled = state.faceIdEnabled
          self.hasPasscode = state.hasPasscode
        }
        if case let .camera(state) = self.destination {
          self.cameraStatus = state.cameraStatus
        }
        if case let .microphone(state) = self.destination {
          self.microphoneStatus = state.microphoneStatus
        }
      }
    }
    public enum Destination: Equatable {
      case appearance(Appearance.State)
      case language(Language.State)
      case activate(Activate.State)
      case menu(Menu.State)
      case camera(Camera.State)
      case microphone(Microphone.State)
      case export(Export.State)
      case agreements(Agreements.State)
      case about(About.State)
    }
    
    var appearance: Appearance.State? {
      get {
        guard case let .appearance(state) = self.destination else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.destination = .appearance(newValue)
      }
    }
    var languageState: Language.State? {
      get {
        guard case let .language(state) = self.destination else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.destination = .language(newValue)
      }
    }
    var activate: Activate.State? {
      get {
        guard case let .activate(state) = self.destination else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.destination = .activate(newValue)
      }
    }
    var menu: Menu.State? {
      get {
        guard case let .menu(state) = self.destination else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.destination = .menu(newValue)
      }
    }
    var camera: Camera.State? {
      get {
        guard case let .camera(state) = self.destination else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.destination = .camera(newValue)
      }
    }
    var microphone: Microphone.State? {
      get {
        guard case let .microphone(state) = self.destination else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.destination = .microphone(newValue)
      }
    }
    var export: Export.State? {
      get {
        guard case let .export(state) = self.destination else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.destination = .export(newValue)
      }
    }
    var agreements: Agreements.State? {
      get {
        guard case let .agreements(state) = self.destination else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.destination = .agreements(newValue)
      }
    }
    var about: About.State? {
      get {
        guard case let .about(state) = self.destination else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.destination = .about(newValue)
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
      route: Destination? = nil
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
      self.destination = route
    }
  }
  
  public enum Action: Equatable {
    case onAppear
    
    case toggleShowSplash(isOn: Bool)
    case biometricResult(LocalAuthenticationType)
    
    case appearance(Appearance.Action)
    case navigateAppearance(Bool)
    
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
    
    case about(About.Action)
    case navigateAbout(Bool)
  }
  
  @Dependency(\.mainQueue) private var mainQueue
  @Dependency(\.localAuthenticationClient) private var localAuthenticationClient
  @Dependency(\.storeKitClient) private var storeKitClient
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .ifLet(\.appearance, action: /Action.appearance) {
        Appearance()
      }
      .ifLet(\.agreements, action: /Action.agreements) {
        Agreements()
      }
      .ifLet(\.camera, action: /Action.camera) {
        Camera()
      }
      .ifLet(\.about, action: /Action.about) {
        About()
      }
      .ifLet(\.export, action: /Action.export) {
        Export()
      }
      .ifLet(\.languageState, action: /Action.language) {
        Language()
      }
      .ifLet(\.microphone, action: /Action.microphone) {
        Microphone()
      }
      .ifLet(\.activate, action: /Action.activate) {
        Activate()
      }
      .ifLet(\.menu, action: /Action.menu) {
        Menu()
      }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action> {
    switch action {
      
    case .onAppear:
      return .run { send in
        await send(.biometricResult(self.localAuthenticationClient.determineType()))
      }
      
    case let .navigateAppearance(value):
      state.destination = value ? .appearance(
        .init(
          styleType: state.styleType,
          layoutType: state.layoutType,
          themeType: state.themeType,
          iconAppType: state.iconAppType
        )
      ) : nil
      return .none
      
    case .appearance:
      return .none
      
    case let .navigateLanguage(value):
      state.destination = value ? .language(
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
      state.destination = value ? .activate(
        .init(
          faceIdEnabled: state.faceIdEnabled,
          hasPasscode: state.hasPasscode
        )
      ) : nil
      return .none
      
    case .menu:
      return .none
      
    case let .navigateMenu(value):
      state.destination = value ? .menu(
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
      state.destination = value ? .microphone(
        .init(microphoneStatus: state.microphoneStatus)
      ) : nil
      return .none
      
    case .camera:
      return .none
      
    case let .navigateCamera(value):
      state.destination = value ? .camera(
        .init(cameraStatus: state.cameraStatus)
      ) : nil
      return .none
      
    case let .navigateAgreements(value):
      state.destination = value ? .agreements(.init()) : nil
      return .none
      
    case .agreements:
      return .none
      
    case .reviewStoreKit:
      return .fireAndForget { await self.storeKitClient.requestReview() }
      
    case let .navigateExport(value):
      state.destination = value ? .export(.init()) : nil
      return .none
      
    case .export:
      return .none
      
    case let .navigateAbout(value):
      state.destination = value ? .about(.init()) : nil
      return .none
      
    case .about:
      return .none
    }
  }
}
