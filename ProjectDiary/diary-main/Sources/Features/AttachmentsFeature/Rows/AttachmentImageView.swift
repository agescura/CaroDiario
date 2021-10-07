//
//  AddEntryImagesView.swift
//  ProjectDiary
//
//  Created by Albert Gil Escura on 4/7/21.
//

import SwiftUI
import ComposableArchitecture
import CoreDataClient
import FileClient
import SharedViews
import SharedModels
import UIApplicationClient

public struct AttachmentImageState: Equatable {
    public var entryImage: SharedModels.EntryImage

    public init(
        entryImage: SharedModels.EntryImage
    ) {
        self.entryImage = entryImage
    }
}

public enum AttachmentImageAction: Equatable {
    case presentImageFullScreen(Bool)
}

public let attachmentImageReducer = Reducer<AttachmentImageState, AttachmentImageAction, Void> { state, action, _ in
    switch action {
    
    case let .presentImageFullScreen(value):
        return .none
    }
}

struct AttachmentImageView: View {
    let store: Store<AttachmentImageState, AttachmentImageAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ImageView(url: viewStore.entryImage.thumbnail)
                .frame(width: 52, height: 52)
                .onTapGesture {
                    viewStore.send(.presentImageFullScreen(true))
                }
        }
    }
}
