import ComposableArchitecture
import Foundation

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
		case animation(Animation)
		case delegate(Delegate)
		case startAnimation
		
		public enum Animation: Equatable {
			case area
			case finish
			case start
			case verticalLine
		}
		
		public enum Delegate: Equatable {
			case finishAnimation
		}
	}
	
	@Dependency(\.mainQueue) private var mainQueue
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .animation(.start):
					return .run { send in
						try await self.mainQueue.sleep(for: .seconds(1))
						await send(.animation(.verticalLine))
					}
					
				case .animation(.verticalLine):
					state.animation = .verticalLine
					return .run { send in
						try await self.mainQueue.sleep(for: .seconds(1))
						await send(.animation(.area))
					}
					
				case .animation(.area):
					state.animation = .horizontalArea
					return .run { send in
						try await self.mainQueue.sleep(for: .seconds(1))
						await send(.animation(.finish))
					}
					
				case .animation(.finish):
					state.animation = .finish
					return .send(.delegate(.finishAnimation))
					
				case .delegate:
					return .none
					
				case .startAnimation:
					return .send(.animation(.start))
			}
		}
	}
}

