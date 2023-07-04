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
      case finished
    }
  }
  
  @Dependency(\.mainQueue) private var mainQueue
  
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .area:
					state.animation = .horizontalArea
					return .none
					
				case .delegate:
					return .none
					
				case .finish:
					state.animation = .finish
					return .none
					
				case .start:
					return .run { send in
						await send(.verticalLine)
						try await self.mainQueue.sleep(for: .seconds(1))
						await send(.area)
						try await self.mainQueue.sleep(for: .seconds(1))
						await send(.finish)
						await send(.delegate(.finished))
						
					}
					
				case .verticalLine:
					state.animation = .verticalLine
					return .none
			}
		}
	}
}
