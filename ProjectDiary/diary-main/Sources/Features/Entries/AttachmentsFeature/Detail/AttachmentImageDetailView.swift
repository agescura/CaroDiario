import ComposableArchitecture
import SwiftUI
import Models
import Views

public struct AttachmentImageDetail: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var entryImage: EntryImage
    
    public var removeFullScreenAlert: AlertState<Action>?
    public var removeAlert: AlertState<Action>?
    
    public var imageScale: CGFloat = 1
    public var lastValue: CGFloat = 1
    public var dragged: CGSize = .zero
    public var previousDragged: CGSize = .zero
    public var pointTapped: CGPoint = .zero
    public var isTapped: Bool = false
    public var currentPosition: CGSize = .zero
    
    public init(
      attachment: AttachmentImage.State
    ) {
      self.entryImage = attachment.entryImage
    }
  }
  
  public enum Action: Equatable {
    case scaleOnChanged(CGFloat)
    case scaleTapGestureCount
    case dragGesture(DragGesture.Value)
  }
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action, Never> {
    switch action {
    case let .scaleOnChanged(value):
      let maxScale: CGFloat = 3.0
      let minScale: CGFloat = 1.0
      
      let resolvedDelta = value / state.imageScale
      state.lastValue = value
      let newScale = state.imageScale * resolvedDelta
      state.imageScale = min(maxScale, max(minScale, newScale))
      return .none
      
    case .scaleTapGestureCount:
      state.isTapped.toggle()
      state.imageScale = state.imageScale > 1 ? 1 : 2
      state.currentPosition = .zero
      return .none
      
    case let .dragGesture(value):
      state.currentPosition = .init(width: value.translation.width, height: value.translation.height)
      return .none
    }
  }
}

public struct AttachmentImageDetailView: View {
  let store: StoreOf<AttachmentImageDetail>
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ImageView(url: viewStore.entryImage.url)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeIn(duration: 1.0), value: UUID())
        .scaleEffect(viewStore.imageScale)
        .offset(viewStore.currentPosition)
        .gesture(
          
          MagnificationGesture(minimumScaleDelta: 0.1)
            .onChanged({ value in
              viewStore.send(.scaleOnChanged(value))
            })
            .simultaneously(with: TapGesture(count: 2).onEnded({
              viewStore.send(.scaleTapGestureCount, animation: .spring())
            }))
        )
    }
  }
}
