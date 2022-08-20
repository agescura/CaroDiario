//
//  AttachmentAddRowView.swift
//
//  Created by Albert Gil Escura on 6/10/21.
//

import SwiftUI
import ComposableArchitecture
import Models

public struct AttachmentAddRowState: Identifiable, Equatable, Hashable {
    public let id: UUID
    public var attachment: AttachmentAddState
    
    public init(
        id: UUID,
        attachment: AttachmentAddState
    ) {
        self.id = id
        self.attachment = attachment
    }
}

public enum AttachmentAddRowAction: Equatable {
    case attachment(AttachmentAddAction)
}

public struct AttachmentAddRowView: View {
    let store: Store<AttachmentAddRowState, AttachmentAddRowAction>
    
    public init(
        store: Store<AttachmentAddRowState, AttachmentAddRowAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        AttachmentAddView(
            store: store.scope(
                state: \.attachment,
                action: AttachmentAddRowAction.attachment
            )
        )
    }
}
