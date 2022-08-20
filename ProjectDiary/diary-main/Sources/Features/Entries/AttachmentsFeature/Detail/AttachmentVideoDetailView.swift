//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 4/10/21.
//

import ComposableArchitecture
import SwiftUI
import AVKit
import Models

public struct AttachmentVideoDetailState: Equatable {
    public var entryVideo: EntryVideo
    
    public init(
        attachment: AttachmentVideoState
    ) {
        self.entryVideo = attachment.entryVideo
    }
}

public enum AttachmentVideoDetailAction: Equatable {}

public let attachmentVideoDetailReducer = Reducer<
    AttachmentVideoDetailState,
    AttachmentVideoDetailAction,
    Void
> { state, action, _ in
    return .none
}

public struct AttachmentVideoDetailView: View {
    let store: Store<AttachmentVideoDetailState, AttachmentVideoDetailAction>
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VideoPlayer(player: AVPlayer(url: viewStore.entryVideo.url))
                .padding(.bottom, 32)
        }
    }
}
