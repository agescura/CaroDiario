import Foundation
import ComposableArchitecture

public struct Splash: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var animation: AnimationState
    
    public init(
      animation: AnimationState = .start
    ) {
      self.animation = animation
    }
    
    public enum AnimationState: Equatable {
      case start
      case verticalLine
      case horizontalArea
      case finish
    }
  }
  
  public enum Action: Equatable {
    case startAnimation
    case verticalLineAnimation
    case areaAnimation
    case finishAnimation
  }
  
  @Dependency(\.mainQueue) private var mainQueue
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action, Never> {
    switch action {
    case .startAnimation:
      return .run { send in
        try await self.mainQueue.sleep(for: .seconds(1))
        await send(.verticalLineAnimation)
      }
      
    case .verticalLineAnimation:
      state.animation = .verticalLine
      return .run { send in
        try await self.mainQueue.sleep(for: .seconds(1))
        await send(.areaAnimation)
      }
      
    case .areaAnimation:
      state.animation = .horizontalArea
      return .run { send in
        try await self.mainQueue.sleep(for: .seconds(1))
        await send(.finishAnimation)
      }
      
    case .finishAnimation:
      state.animation = .finish
      return .none
    }
  }
}

