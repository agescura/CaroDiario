//
//  AddEntryImageRowView.swift
//  ProjectDiary
//
//  Created by Albert Gil Escura on 4/7/21.
//

import SwiftUI
import ComposableArchitecture
import SharedModels

public struct AttachmentRowState: Identifiable, Equatable {
    public let id: UUID
    public var attachment: AttachmentState
    
    public init(
        id: UUID,
        attachment: AttachmentState
    ) {
        self.id = id
        self.attachment = attachment
    }
}

public enum AttachmentRowAction: Equatable {
    case attachment(AttachmentAction)
}

public struct AttachmentRowView: View {
    let store: Store<AttachmentRowState, AttachmentRowAction>
    
    public init(
        store: Store<AttachmentRowState, AttachmentRowAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        AttachmentView(
            store: store.scope(
                state: \.attachment,
                action: AttachmentRowAction.attachment
            )
        )
    }
}
