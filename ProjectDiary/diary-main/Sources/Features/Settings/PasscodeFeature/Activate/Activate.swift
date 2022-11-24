import Foundation
import ComposableArchitecture

public struct Activate: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var faceIdEnabled: Bool
    public var hasPasscode: Bool
    
    public var route: Route? {
      didSet {
        if case let .insert(state) = self.route {
          self.faceIdEnabled = state.faceIdEnabled
          self.hasPasscode = state.hasPasscode
        }
      }
    }
    
    public enum Route: Equatable {
      case insert(Insert.State)
    }
    
    public var insert: Insert.State? {
      get {
        guard case let .insert(state) = self.route else { return nil }
        return state
      }
      set {
        guard let newValue = newValue else { return }
        self.route = .insert(newValue)
      }
    }
    
    public init(
      faceIdEnabled: Bool,
      hasPasscode: Bool
    ) {
      self.faceIdEnabled = faceIdEnabled
      self.hasPasscode = hasPasscode
    }
  }
  
  public enum Action: Equatable {
    case insert(Insert.Action)
    case navigateInsert(Bool)
  }
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .ifLet(\.insert, action: /Action.insert) {
        Insert()
      }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action, Never> {
    switch action {
      
    case .insert:
      return .none
      
    case let .navigateInsert(value):
      state.route = value ? .insert(
        .init(faceIdEnabled: state.faceIdEnabled)
      ) : nil
      return .none
    }
  }
}
