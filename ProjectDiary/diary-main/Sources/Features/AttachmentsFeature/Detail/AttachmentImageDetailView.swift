//
//  AttachmentAudioDetailView.swift
//  
//
//  Created by Albert Gil Escura on 4/10/21.
//

import ComposableArchitecture
import SwiftUI
import SharedModels
import SharedViews

public struct AttachmentImageDetailState: Equatable {
    public var entryImage: EntryImage
    
    public var removeFullScreenAlert: AlertState<AttachmentImageDetailAction>?
    public var removeAlert: AlertState<AttachmentImageDetailAction>?
    
    public var imageScale: CGFloat = 1
    public var lastValue: CGFloat = 1
    public var dragged: CGSize = .zero
    public var previousDragged: CGSize = .zero
    public var pointTapped: CGPoint = .zero
    public var isTapped: Bool = false
    public var currentPosition: CGSize = .zero
    
    public init(
        attachment: AttachmentImageState
    ) {
        self.entryImage = attachment.entryImage
    }
}

public enum AttachmentImageDetailAction: Equatable {
    case scaleOnChanged(CGFloat)
    case scaleTapGestureCount
    case dragGesture(DragGesture.Value)
}

public let attachmentImageDetailReducer = Reducer<AttachmentImageDetailState, AttachmentImageDetailAction, Void> { state, action, _ in
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

public struct AttachmentImageDetailView: View {
    let store: Store<AttachmentImageDetailState, AttachmentImageDetailAction>
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            ImageView(url: viewStore.entryImage.url)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.easeIn(duration: 1.0))
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
