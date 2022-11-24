import Foundation
import ComposableArchitecture
import LocalAuthenticationClient
import UserDefaultsClient
import Models
import SwiftUIHelper

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

public struct Menu: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var authenticationType: LocalAuthenticationType
    public var route: Route?
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
    
    public enum Route: Equatable {
      case disabled(ActionViewModel<Menu.Action>)
    }
    
    public init(
      authenticationType: LocalAuthenticationType,
      optionTimeForAskPasscode: Int,
      faceIdEnabled: Bool,
      route: Route? = nil
    ) {
      self.authenticationType = authenticationType
      self.optionTimeForAskPasscode = TimeForAskPasscode(optionTimeForAskPasscode)
      self.faceIdEnabled = faceIdEnabled
      self.route = route
    }
  }
  
  public enum Action: Equatable {
    case popToRoot
    case actionSheetButtonTapped
    case actionSheetCancelTapped
    case actionSheetTurnoffTapped
    case toggleFaceId(isOn: Bool)
    case faceId(response: Bool)
    case optionTimeForAskPasscode(changed: TimeForAskPasscode)
  }
  
  @Dependency(\.mainQueue) private var mainQueue
  @Dependency(\.localAuthenticationClient) private var localAuthenticationClient
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action, Never> {
    switch action {
    case .popToRoot:
      return .none
      
    case .actionSheetButtonTapped:
      state.route = .disabled(
        .init(
          "Passcode.Turnoff.Message".localized(with: [state.authenticationType.rawValue]),
          buttons: [
            .init("Cancel".localized, role: .cancel, action: .actionSheetCancelTapped),
            .init("Passcode.Turnoff".localized, action: .actionSheetTurnoffTapped)
          ]
        )
      )
      return .none
      
    case .actionSheetCancelTapped:
      state.route = nil
      return .none
      
    case .actionSheetTurnoffTapped:
      state.route = nil
      return .none
      
    case let .toggleFaceId(isOn: value):
      if !value {
        return Effect(value: .faceId(response: value))
      }
      return .run { [state] send in
        await send(.faceId(response: self.localAuthenticationClient.evaluate("Settings.Biometric.Test".localized(with: [state.authenticationType.rawValue]))))
      }
      
    case let .faceId(response: response):
      state.faceIdEnabled = response
      return .none
      
    case let .optionTimeForAskPasscode(changed: newOption):
      state.optionTimeForAskPasscode = newOption
      return .none
    }
  }
}
