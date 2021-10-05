//
//  SwiftUIView.swift
//  
//
//  Created by Albert Gil Escura on 3/8/21.
//

import SwiftUI
import ComposableArchitecture
import CoreDataClient
import FileClient
import SharedViews
import SharedModels
import SharedLocalizables
import UIApplicationClient
import AVKit

public struct AttachmentVideoState: Equatable {
    public var entryVideo: SharedModels.EntryVideo
    public var presentVideoPlayer: Bool = false
    
    public init(
        entryVideo: SharedModels.EntryVideo
    ) {
        self.entryVideo = entryVideo
    }
}

public enum AttachmentVideoAction: Equatable {
    case presentVideoPlayer(Bool)
}

public let attachmentVideoReducer = Reducer<AttachmentVideoState, AttachmentVideoAction, Void> { state, action, environment in
    switch action {
    
    case let .presentVideoPlayer(value):
        return .none
    }
}

struct AttachmentVideoView: View {
    let store: Store<AttachmentVideoState, AttachmentVideoAction>

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

