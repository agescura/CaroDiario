//
//  AttachmentAddVideo.swift
//
//  Created by Albert Gil Escura on 6/10/21.
//

import SwiftUI
import ComposableArchitecture
import CoreDataClient
import FileClient
import SharedViews
import SharedModels
import SharedLocalizables
import UIApplicationClient

public struct AttachmentAddVideoState: Equatable {
    public var entryVideo: SharedModels.EntryVideo
    public var presentVideoPlayer: Bool = false
    
    public init(
        entryVideo: SharedModels.EntryVideo
    ) {
        self.entryVideo = entryVideo
    }
}

public enum AttachmentAddVideoAction: Equatable {
    case presentVideoPlayer(Bool)
}

public let attachmentAddVideoReducer = Reducer<AttachmentAddVideoState, AttachmentAddVideoAction, Void> { state, action, environment in
    switch action {
    
    case let .presentVideoPlayer(value):
        return .none
    }
}

struct AttachmentAddVideoView: View {
    let store: Store<AttachmentAddVideoState, AttachmentAddVideoAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                ImageView(url: viewStore.entryVideo.thumbnail)
                    .frame(width: 52, height: 52)
                Image(systemName: "play.fill")
                    .foregroundColor(.adaptiveWhite)
                    .frame(width: 8, height: 8)
            }
            .onTapGesture {
                viewStore.send(.presentVideoPlayer(true))
            }
        }
    }
}

