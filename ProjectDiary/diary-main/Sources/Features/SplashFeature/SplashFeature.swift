import Foundation
import ComposableArchitecture

public struct SplashFeature: Reducer {
  public init() {}
  
  public struct State: Equatable {
    public var animation: AnimationState
    
    public init(
      animation: AnimationState = .start
    ) {
      self.animation = animation
    }
    
    public enum AnimationState: Equatable {
			case finish
			case horizontalArea
      case start
      case verticalLine
    }
  }
  
  public enum Action: Equatable {
		case areaAnimation
		case finishAnimation
    case startAnimation
    case verticalLineAnimation
  }
  
  @Dependency(\.continuousClock) var clock
  
  public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .areaAnimation:
					state.animation = .horizontalArea
					return .run { send in
						try await self.clock.sleep(for: .seconds(1))
						await send(.finishAnimation)
					}
					
				case .finishAnimation:
					state.animation = .finish
					return .none
					
				case .startAnimation:
					return .run { send in
						try await self.clock.sleep(for: .seconds(1))
						await send(.verticalLineAnimation)
					}
					
				case .verticalLineAnimation:
					state.animation = .verticalLine
					return .run { send in
						try await self.clock.sleep(for: .seconds(1))
						await send(.areaAnimation)
					}
			}
		}
	}
}
