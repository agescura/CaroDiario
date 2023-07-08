import ComposableArchitecture
import Styles
import SwiftUI

public struct SplashView: View {
	private let store: StoreOf<SplashFeature>
	
	public init(
		store: StoreOf<SplashFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: \.animation
		) { viewStore in
			ZStack {
				Color.chambray
				
				HStack {
					Divider()
						.frame(
							minWidth: 1,
							maxWidth: viewStore.state.lineWidth,
							minHeight: 0,
							maxHeight: viewStore.state.lineHeight
						)
						.background(Color.adaptiveWhite)
						.animation(viewStore.state.duration, value: UUID())
				}
			}
			.ignoresSafeArea()
		}
	}
}

extension SplashFeature.State.AnimationState {
	var lineHeight: CGFloat {
		switch self {
			case .start:
				return 0
			case .verticalLine, .horizontalArea, .finish:
				return .infinity
		}
	}
	
	var lineWidth: CGFloat {
		switch self {
			case .start, .verticalLine:
				return 1
			case .horizontalArea, .finish:
				return .infinity
		}
	}
	
	var duration: Animation? {
		switch self {
			case .start, .verticalLine, .horizontalArea:
				return .easeOut(duration: 0.5)
			case .finish:
				return nil
		}
	}
}
