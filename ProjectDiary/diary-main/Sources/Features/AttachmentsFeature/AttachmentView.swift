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
}

public enum AttachmentAction: Equatable {
    case image(AttachmentImageAction)
    case video(AttachmentVideoAction)
    case audio(AttachmentAudioAction)
}

public struct AttachmentEnvironment {
    public let fileClient: FileClient
    public let applicationClient: UIApplicationClient
    public var avAudioPlayerClient: AVAudioPlayerClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    
    public init(
        fileClient: FileClient,
        applicationClient: UIApplicationClient,
        avAudioPlayerClient: AVAudioPlayerClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.fileClient = fileClient
        self.applicationClient = applicationClient
        self.avAudioPlayerClient = avAudioPlayerClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
    }
}

public let attachmentReducer: Reducer<AttachmentState, AttachmentAction, AttachmentEnvironment> = .combine(
    
    attachmentImageReducer
        .pullback(
            state: /AttachmentState.image,
            action: /AttachmentAction.image,
            environment: { AttachmentImageEnvironment(
                fileClient: $0.fileClient,
                applicationClient: $0.applicationClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue)
            }
        ),
    
    attachmentVideoReducer
        .pullback(
            state: /AttachmentState.video,
            action: /AttachmentAction.video,
            environment: { AttachmentVideoEnvironment(
                fileClient: $0.fileClient,
                applicationClient: $0.applicationClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue)
            }
        ),
    
    attachmentAudioReducer
        .pullback(
            state: /AttachmentState.audio,
            action: /AttachmentAction.audio,
            environment: { AttachmentAudioEnvironment(
                fileClient: $0.fileClient,
                applicationClient: $0.applicationClient,
                avAudioPlayerClient: $0.avAudioPlayerClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue)
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
