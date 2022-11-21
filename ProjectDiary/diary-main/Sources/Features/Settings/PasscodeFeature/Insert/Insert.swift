//
import Foundation
import ComposableArchitecture

public struct Insert: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var step: Step = .firstCode
    public var code: String = ""
    public var firstCode: String = ""
    public let maxNumbersCode = 4
    public var codeActivated: Bool = false
    public var codeNotMatched: Bool = false
    
    public var faceIdEnabled: Bool
    public var hasPasscode: Bool {
      self.code == self.firstCode && self.code.count == self.maxNumbersCode
    }
    public var route: Route? {
      didSet {
        if case let .menu(state) = self.route {
          self.faceIdEnabled = state.faceIdEnabled
        }
      }
    }
    
    public enum Route: Equatable {
      case menu(Menu.State)
    }
    
    public var menuPasscodeState: Menu.State? {
      get {
        guard case let .menu(state) = self.route else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.route = .menu(newValue)
      }
    }
    
    public init(
      faceIdEnabled: Bool,
      route: Route? = nil
    ) {
      self.faceIdEnabled = faceIdEnabled
      self.route = route
    }
    
    public enum Step: Int {
      case firstCode
      case secondCode
      
      var title: String {
        switch self {
        case .firstCode:
          return "Passcode.Insert".localized
        case .secondCode:
          return "Passcode.Reinsert".localized
        }
      }
    }
  }

  public enum Action: Equatable {
    case update(code: String)
    case success
    case popToRoot
    case menuPasscodeAction(Menu.Action)
    case navigateMenuPasscode(Bool)
  }
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .ifLet(\.menuPasscodeState, action: /Action.menuPasscodeAction) {
        Menu()
      }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action, Never> {
    switch action {
    case let .update(code: code):
      state.code = code
      if state.step == .firstCode,
         state.code.count == state.maxNumbersCode {
        state.codeNotMatched = false
        state.firstCode = state.code
        state.step = .secondCode
        state.code = ""
      }
      if state.step == .secondCode,
         state.code.count == state.maxNumbersCode {
        if state.code == state.firstCode {
          return Effect(value: .navigateMenuPasscode(true))
        } else {
          state.step = .firstCode
          state.code = ""
          state.firstCode = ""
          state.codeNotMatched = true
        }
      }
      return .none
      
    case .success:
      return .none
      
    case .popToRoot:
      return .none
      
    case .menuPasscodeAction:
      return .none
      
    case let .navigateMenuPasscode(value):
      state.route = value ? .menu(
        .init(
          authenticationType: .none,
          optionTimeForAskPasscode: TimeForAskPasscode.never.value,
          faceIdEnabled: state.faceIdEnabled
        )
      ) : nil
      return .none
    }
  }
}
