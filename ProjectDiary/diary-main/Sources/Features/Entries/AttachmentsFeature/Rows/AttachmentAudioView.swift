//
//  AttachmentAudioView.swift
//  
//
//  Created by Albert Gil Escura on 24/8/21.
//

import SwiftUI
import ComposableArchitecture
import CoreDataClient
import FileClient
import Views
import Models
import UIApplicationClient
import AVAudioPlayerClient

public struct AttachmentAudioState: Equatable {
    public var entryAudio: EntryAudio
    
    public init(
        entryAudio: EntryAudio
    ) {
        self.entryAudio = entryAudio
    }
}

public enum AttachmentAudioAction: Equatable {
    case presentAudioFullScreen(Bool)
}

public let attachmentAudioReducer = Reducer<
    AttachmentAudioState,
    AttachmentAudioAction,
    Void
> { state, action, _ in
    switch action {
    case let .presentAudioFullScreen(value):
        return .none
    }
}

struct AttachmentAudioView: View {
    let store: Store<AttachmentAudioState, AttachmentAudioAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            Rectangle()
                .fill(Color.adaptiveGray)
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: "waveform")
                        .foregroundColor(.adaptiveWhite)
                        .frame(width: 8, height: 8)
                )
                .onTapGesture {
                    viewStore.send(.presentAudioFullScreen(true))
                }
        }
    }
}
