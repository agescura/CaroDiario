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
import AVKit

public struct AttachmentAddVideoState: Equatable {
    public var entryVideo: SharedModels.EntryVideo
    public var presentVideoPlayer: Bool = false
        
    public var videoAlert: AlertState<AttachmentAddVideoAction>?
    
    public init(
        entryVideo: SharedModels.EntryVideo
    ) {
        self.entryVideo = entryVideo
    }
}

public enum AttachmentAddVideoAction: Equatable {
    case presentVideoPlayer(Bool)
    case videoAlertButtonTapped
    case dismissRemoveFullScreen
    case remove
    case cancelRemoveFullScreenAlert
}

public let attachmentAddVideoReducer = Reducer<AttachmentAddVideoState, AttachmentAddVideoAction, Void> { state, action, _ in
    switch action {
        
    case let .presentVideoPlayer(value):
        state.presentVideoPlayer = value
        return .none
        
    case .videoAlertButtonTapped:
        state.videoAlert = .init(
            title: .init("Video.Remove.Description".localized),
            primaryButton: .cancel(.init("Cancel".localized)),
            secondaryButton: .destructive(.init("Video.Remove.Title".localized), action: .send(.remove))
        )
        return .none
        
    case .dismissRemoveFullScreen:
        state.videoAlert = nil
        state.presentVideoPlayer = false
        return .none
        
    case .remove:
        state.presentVideoPlayer = false
        state.videoAlert = nil
        return .none
        
    case .cancelRemoveFullScreenAlert:
        state.videoAlert = nil
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
            .fullScreenCover(isPresented: viewStore.binding(
                                get: \.presentVideoPlayer,
                                send: AttachmentAddVideoAction.presentVideoPlayer)
            ) {
                ZStack {
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        HStack(spacing: 8) {
                            Spacer()
                            Button(action: {
                                viewStore.send(.videoAlertButtonTapped)
                            }) {
                                Image(systemName: "trash")
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.chambray)
                            }
                            
                            Button(action: {
                                viewStore.send(.presentVideoPlayer(false))
                            }) {
                                Image(systemName: "xmark")
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.chambray)
                            }
                        }
                        
                        VideoPlayer(player: AVPlayer(url: viewStore.entryVideo.url))
                            .edgesIgnoringSafeArea([.bottom, .horizontal])
                    }
                    .alert(
                        store.scope(state: \.videoAlert),
                        dismiss: .cancelRemoveFullScreenAlert
                    )
                }
            }
        }
    }
}

