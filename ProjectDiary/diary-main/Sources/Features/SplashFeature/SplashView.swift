import SwiftUI
import ComposableArchitecture
import Styles

public struct SplashView: View {
  let store: StoreOf<Splash>
  
  public init(
    store: StoreOf<Splash>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ZStack {
        Color.chambray
        
        HStack {
          Divider()
            .frame(
              minWidth: 1,
              maxWidth: viewStore.animation.lineWidth,
              minHeight: 0,
              maxHeight: viewStore.animation.lineHeight
            )
            .background(Color.adaptiveWhite)
            .animation(viewStore.animation.duration, value: UUID())
        }
      }
      .ignoresSafeArea()
    }
  }
}

extension Splash.State.AnimationState {
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

struct Splash_Previews: PreviewProvider {
  static var previews: some View {
    SplashView(
      store: .init(
        initialState: Splash.State(
          animation: .start
        ),
        reducer: Splash()
      )
    )
  }
}
