//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 6/10/21.
//

import SwiftUI
import ComposableArchitecture
import SharedModels
import AVAudioPlayerClient
import UIApplicationClient
import FileClient

public enum AttachmentAddState: Equatable {
    case image(AttachmentAddImageState)
    case video(AttachmentAddVideoState)
    case audio(AttachmentAddAudioState)
    
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

extension AttachmentAddState: Hashable {
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

public enum AttachmentAddAction: Equatable {
    case image(AttachmentAddImageAction)
    case video(AttachmentAddVideoAction)
    case audio(AttachmentAddAudioAction)
}

public struct AttachmentAddEnvironment {
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

public let attachmentAddReducer: Reducer<AttachmentAddState, AttachmentAddAction, AttachmentAddEnvironment> = .combine(
    
    attachmentAddImageReducer
        .pullback(
            state: /AttachmentAddState.image,
            action: /AttachmentAddAction.image,
            environment: { AttachmentAddImageEnvironment(
                fileClient: $0.fileClient,
                applicationClient: $0.applicationClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue)
            }
        ),
    
    attachmentAddVideoReducer
        .pullback(
            state: /AttachmentAddState.video,
            action: /AttachmentAddAction.video,
            environment: { _ in ()
            }
        ),
    
    attachmentAddAudioReducer
        .pullback(
            state: /AttachmentAddState.audio,
            action: /AttachmentAddAction.audio,
            environment: { AttachmentAddAudioEnvironment(
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

public struct AttachmentAddView: View {
    let store: Store<AttachmentAddState, AttachmentAddAction>
    
    public var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /AttachmentAddState.image,
                action: AttachmentAddAction.image,
                then: AttachmentAddImageView.init(store:)
            )
            
            CaseLet(
                state: /AttachmentAddState.video,
                action: AttachmentAddAction.video,
                then: AttachmentAddVideoView.init(store:)
            )
            
            CaseLet(
                state: /AttachmentAddState.audio,
                action: AttachmentAddAction.audio,
                then: AttachmentAddAudioView.init(store:)
            )
        }
    }
}
