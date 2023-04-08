import Foundation
import ComposableArchitecture
import LocalAuthenticationClient
import UserDefaultsClient
import Models

public struct LockScreen: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    var code: String
    var codeToMatch: String = ""
    var wrongAttempts: Int = 0
    public var authenticationType: LocalAuthenticationType = .none
    public var buttons: [LockScreenNumber] = []
    
    public init(
      code: String,
      codeToMatch: String = ""
    ) {
      self.code = code
      self.codeToMatch = codeToMatch
    }
  }
  
  public enum Action: Equatable {
    case numberButtonTapped(LockScreenNumber)
    case matchedCode
    case failedCode
    case reset
    case onAppear
    case checkFaceId
    case determine(LocalAuthenticationType)
    case faceIdResponse(Bool)
  }
  
  @Dependency(\.userDefaultsClient) private var userDefaultsClient
  @Dependency(\.localAuthenticationClient) private var localAuthenticationClient
  @Dependency(\.mainQueue) private var mainQueue
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> EffectTask<Action> {
    switch action {
    case let .numberButtonTapped(item):
      if item == .biometric(.touchId) || item == .biometric(.faceId) {
        return EffectTask(value: .checkFaceId)
      }
      if let value = item.value {
        state.codeToMatch.append("\(value)")
      }
      if state.code == state.codeToMatch {
        return EffectTask(value: .matchedCode)
      } else if state.code.count == state.codeToMatch.count {
        return EffectTask(value: .failedCode)
      }
      return .none
      
    case .onAppear:
      return .merge(
        EffectTask(value: .checkFaceId),
        .run { send in
          await send(.determine(self.localAuthenticationClient.determineType()))
        }
      )
      
    case let .determine(type):
      state.authenticationType = type
      
      let leftButton: LockScreenNumber = type == .none || !self.userDefaultsClient.isFaceIDActivate ? .emptyLeft : .biometric(type)
      state.buttons = [
        .number(1),
        .number(2),
        .number(3),
        .number(4),
        .number(5),
        .number(6),
        .number(7),
        .number(8),
        .number(9),
        leftButton,
        .number(0),
        .emptyRight
      ]
      return .none
      
    case .checkFaceId:
      
      if self.userDefaultsClient.isFaceIDActivate {
        return .run { send in
          await send(.faceIdResponse(self.localAuthenticationClient.evaluate("JIJIJAJAJ")))
        }
      } else {
        return .none
      }
      
    case let .faceIdResponse(value):
      if value {
        return EffectTask(value: .matchedCode)
          .delay(for: 0.5, scheduler: self.mainQueue)
          .eraseToEffect()
      }
      return .none
      
    case .matchedCode:
      return .none
      
    case .failedCode:
      state.wrongAttempts = 4
      state.codeToMatch = ""
      return EffectTask(value: .reset)
        .delay(for: 0.5, scheduler: self.mainQueue)
        .eraseToEffect()
      
    case .reset:
      state.wrongAttempts = 0
      return .none
    }
  }
}
