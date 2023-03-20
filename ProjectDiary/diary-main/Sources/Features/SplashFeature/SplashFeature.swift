import Foundation
import ComposableArchitecture

public struct SplashFeature: ReducerProtocol {
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
    case area
    case delegate(Delegate)
    case finish
    case start
    case verticalLine
    
    public enum Delegate {
      case completeAnimation
    }
  }
  
  @Dependency(\.continuousClock) private var clock
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> EffectTask<Action> {
    switch action {
    case .area:
      state.animation = .horizontalArea
      return .run { send in
        try await self.clock.sleep(for: .seconds(1))
        await send(.finish)
      }
      
    case .delegate(.completeAnimation):
      return .none
      
    case .finish:
      state.animation = .finish
      return .none
      
    case .start:
      return .run { send in
        try await self.clock.sleep(for: .seconds(1))
        await send(.verticalLine)
      }
      
    case .verticalLine:
      state.animation = .verticalLine
      return .run { send in
        try await self.clock.sleep(for: .seconds(1))
        await send(.area)
      }
    }
  }
}
