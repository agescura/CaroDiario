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
      return Effect(value: .verticalLineAnimation)
        .delay(for: 1, scheduler: self.mainQueue)
        .eraseToEffect()
      
    case .verticalLineAnimation:
      state.animation = .verticalLine
      return Effect(value: .areaAnimation)
        .delay(for: 1, scheduler: self.mainQueue)
        .eraseToEffect()
      
    case .areaAnimation:
      state.animation = .horizontalArea
      return Effect(value: .finishAnimation)
        .delay(for: 1, scheduler: self.mainQueue)
        .eraseToEffect()
      
    case .finishAnimation:
      state.animation = .finish
      return .none
    }
  }
}

