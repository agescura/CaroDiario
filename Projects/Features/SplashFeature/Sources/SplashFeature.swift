import Foundation
import ComposableArchitecture

@Reducer
public struct SplashFeature {
  public init() {}
  
	@ObservableState
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
  
  public enum Action: ViewAction, Equatable {
		case areaAnimation
		case delegate(Delegate)
		case finishAnimation
    case verticalLineAnimation
		case view(View)
		
		@CasePathable
		public enum Delegate: Equatable {
			case animationFinished
		}
		@CasePathable
		public enum View: Equatable {
			case task
		}
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
				case .delegate:
					return .none
				case .finishAnimation:
					state.animation = .finish
					return .send(.delegate(.animationFinished))
				case let .view(viewAction):
					switch viewAction {
						case .task:
							return .run { send in
								try await self.clock.sleep(for: .seconds(1))
								await send(.verticalLineAnimation)
							}
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
