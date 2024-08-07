import SwiftUI
import ComposableArchitecture
import Styles

public struct SplashView: View {
	let store: StoreOf<SplashFeature>
	
	public init(
		store: StoreOf<SplashFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		ZStack {
			Color.chambray
			
			HStack {
				Divider()
					.frame(
						minWidth: 1,
						maxWidth: self.store.animation.lineWidth,
						minHeight: 0,
						maxHeight: self.store.animation.lineHeight
					)
					.background(Color.adaptiveWhite)
					.animation(self.store.animation.duration, value: UUID())
			}
		}
		.ignoresSafeArea()
		.task { await self.store.send(.task).finish() }
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

#Preview {
	SplashView(
		store: Store(
			initialState: SplashFeature.State(
				animation: .start
			),
			reducer: { SplashFeature() }
		)
	)
}
