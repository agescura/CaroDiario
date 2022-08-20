//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 4/10/21.
//

import ComposableArchitecture
import SwiftUI
import FileClient
import UIApplicationClient
import AVAudioPlayerClient

public enum AttachmentDetailState: Equatable {
    case image(AttachmentImageDetailState)
    case video(AttachmentVideoDetailState)
    case audio(AttachmentAudioDetailState)
    
    public init(row: AttachmentRowState) {
        switch row.attachment {
        case let .image(attachmentImageState):
            self = .image(AttachmentImageDetailState(attachment: attachmentImageState))
        case let .video(attachmentVideoState):
            self = .video(AttachmentVideoDetailState(attachment: attachmentVideoState))
        case let .audio(attachmentAudioState):
            self = .audio(AttachmentAudioDetailState(attachment: attachmentAudioState))
        }
    }
}

public enum AttachmentDetailAction: Equatable {
    case image(AttachmentImageDetailAction)
    case video(AttachmentVideoDetailAction)
    case audio(AttachmentAudioDetailAction)
}

public struct AttachmentDetailEnvironment {
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

public let attachmentDetailReducer: Reducer<AttachmentDetailState, AttachmentDetailAction, AttachmentDetailEnvironment> = .combine(
    
    attachmentImageDetailReducer
        .pullback(
            state: /AttachmentDetailState.image,
            action: /AttachmentDetailAction.image,
            environment: { _ in ()
            }
        ),
    
    attachmentVideoDetailReducer
        .pullback(
            state: /AttachmentDetailState.video,
            action: /AttachmentDetailAction.video,
            environment: { _ in ()
            }
        ),
    
    attachmentAudioDetailReducer
        .pullback(
            state: /AttachmentDetailState.audio,
            action: /AttachmentDetailAction.audio,
            environment: { AttachmentAudioDetailEnvironment(
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

public struct AttachmentDetailView: View {
    let store: Store<AttachmentDetailState, AttachmentDetailAction>
    
    public init(
        store: Store<AttachmentDetailState, AttachmentDetailAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        SwitchStore(store) {
            CaseLet(
                state: /AttachmentDetailState.image,
                action: AttachmentDetailAction.image,
                then: AttachmentImageDetailView.init(store:)
            )
            
            CaseLet(
                state: /AttachmentDetailState.video,
                action: AttachmentDetailAction.video,
                then: AttachmentVideoDetailView.init(store:)
            )
            
            CaseLet(
                state: /AttachmentDetailState.audio,
                action: AttachmentDetailAction.audio,
                then: AttachmentAudioDetailView.init(store:)
            )
        }
    }
}
