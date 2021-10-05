//
//  AddEntryAttachment.swift
//  
//
//  Created by Albert Gil Escura on 10/8/21.
//

import SwiftUI
import ComposableArchitecture
import SharedModels
import AVAudioPlayerClient
import UIApplicationClient
import FileClient

public enum AttachmentState: Equatable {
    case image(AttachmentImageState)
    case video(AttachmentVideoState)
    case audio(AttachmentAudioState)
    
    public var url: URL {
        switch self {
        case let .image(state):
            return state.entryImage.url
        case let .video(state):
            return state.entryVideo.url
        case let .audio(state):
            return state.entryAudio.url
        }
    }
    
    public var thumbnail: URL? {
        switch self {
        case let .image(state):
            return state.entryImage.thumbnail
        case let .video(state):
            return state.entryVideo.thumbnail
        case .audio:
            return nil
        }
    }
    
    public var attachment: EntryAttachment {
        switch self {
        case let .image(value):
            return value.entryImage
        case let .video(value):
            return value.entryVideo
        case let .audio(value):
            return value.entryAudio
        }
    }
    
    public var date: Date {
        switch self {
        case let .image(value):
            return value.entryImage.lastUpdated
        case let .video(value):
            return value.entryVideo.lastUpdated
        case let .audio(value):
            return value.entryAudio.lastUpdated
        }
    }
}

extension AttachmentState: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .image(state):
            hasher.combine(state.entryImage.id)
        case let .video(state):
            hasher.combine(state.entryVideo.id)
        case let .audio(state):
            hasher.combine(state.entryAudio.id)
        }
    }
}

public enum AttachmentAction: Equatable {
    case image(AttachmentImageAction)
    case video(AttachmentVideoAction)
    case audio(AttachmentAudioAction)
}

public let attachmentReducer: Reducer<AttachmentState, AttachmentAction, Void> = .combine(
    
    attachmentImageReducer
        .pullback(
            state: /AttachmentState.image,
            action: /AttachmentAction.image,
            environment: { _ in ()
            }
        ),
    
    attachmentVideoReducer
        .pullback(
            state: /AttachmentState.video,
            action: /AttachmentAction.video,
            environment: { _ in ()
            }
        ),
    
    attachmentAudioReducer
        .pullback(
            state: /AttachmentState.audio,
            action: /AttachmentAction.audio,
            environment: { _ in ()
            }
        ),
    
    .init { state, action, _ in
        return .none
    }
)

public struct AttachmentView: View {
    let store: Store<AttachmentState, AttachmentAction>
    
    public var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /AttachmentState.image,
                action: AttachmentAction.image,
                then: AttachmentImageView.init(store:)
            )
            
            CaseLet(
                state: /AttachmentState.video,
                action: AttachmentAction.video,
                then: AttachmentVideoView.init(store:)
            )
            
            CaseLet(
                state: /AttachmentState.audio,
                action: AttachmentAction.audio,
                then: AttachmentAudioView.init(store:)
            )
        }
    }
}
