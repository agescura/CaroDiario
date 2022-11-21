import SwiftUI
import ComposableArchitecture
import Views
import UserDefaultsClient
import Localizables
import LocalAuthenticationClient
import SwiftUIHelper
import Models

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
  private var localAuthenticationClient: LocalAuthenticationClient = .noop
  
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
      return self.localAuthenticationClient.evaluate("Settings.Biometric.Test".localized(with: [state.authenticationType.rawValue]))
        .receive(on: self.mainQueue)
        .eraseToEffect()
        .map(Menu.Action.faceId(response:))
      
    case let .faceId(response: response):
      state.faceIdEnabled = response
      return .none
      
    case let .optionTimeForAskPasscode(changed: newOption):
      state.optionTimeForAskPasscode = newOption
      return .none
    }
  }
}

public struct MenuPasscodeView: View {
  let store: StoreOf<Menu>
  
  public init(
    store: StoreOf<Menu>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Form {
        Section(
          footer: Text("Passcode.Activate.Message".localized)
        ) {
          Button(action: {
            viewStore.send(.actionSheetButtonTapped)
          }) {
            Text("Passcode.Turnoff".localized)
              .foregroundColor(.chambray)
          }
          .confirmationDialog(
            route: viewStore.route,
            case: /Menu.State.Route.disabled,
            send: { viewStore.send($0) },
            onDismiss: { viewStore.send(.actionSheetCancelTapped) }
          )
        }
        
        Section(header: Text(""), footer: Text("")) {
          Toggle(
            isOn: viewStore.binding(
              get: \.faceIdEnabled,
              send: Menu.Action.toggleFaceId
            )
          ) {
            Text("Passcode.UnlockFaceId".localized(with: [viewStore.authenticationType.rawValue]))
              .foregroundColor(.chambray)
          }
          .toggleStyle(SwitchToggleStyle(tint: .chambray))
          
          Picker("",  selection: viewStore.binding(
            get: \.optionTimeForAskPasscode,
            send: Menu.Action.optionTimeForAskPasscode
          )) {
            ForEach(viewStore.listTimesForAskPasscode, id: \.self) { type in
              Text(type.rawValue)
                .adaptiveFont(.latoRegular, size: 12)
            }
          }
          .overlay(
            HStack(spacing: 16) {
              Text("Passcode.Autolock".localized)
                .foregroundColor(.chambray)
                .adaptiveFont(.latoRegular, size: 12)
              Spacer()
            }
          )
        }
      }
      .navigationBarItems(
        leading: Button(
          action: {
            viewStore.send(.popToRoot)
          }
        ) {
          Image(.chevronRight)
        }
      )
    }
    .navigationBarTitle("Passcode.Title".localized)
    .navigationBarBackButtonHidden(true)
  }
}
