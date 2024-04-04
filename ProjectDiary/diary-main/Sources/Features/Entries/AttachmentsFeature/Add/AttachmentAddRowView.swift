//
//  AttachmentAddRowView.swift
//
//  Created by Albert Gil Escura on 6/10/21.
//

import SwiftUI
import ComposableArchitecture
import Models

public struct AttachmentAddRow: Reducer {
  public init() {}
  
  public struct State: Identifiable, Equatable, Hashable {
    public let id: UUID
    public var attachment: AttachmentAdd.State
    
    public init(
      id: UUID,
      attachment: AttachmentAdd.State
    ) {
      self.id = id
      self.attachment = attachment
    }
  }
  
  public enum Action: Equatable {
    case attachment(AttachmentAdd.Action)
  }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.attachment, action: /Action.attachment) {
      AttachmentAdd()
    }
  }
}

public struct AttachmentAddRowView: View {
  let store: StoreOf<AttachmentAddRow>
  
  public init(
    store: StoreOf<AttachmentAddRow>
  ) {
    self.store = store
  }
  
  public var body: some View {
    AttachmentAddView(
      store: store.scope(
        state: \.attachment,
        action: AttachmentAddRow.Action.attachment
      )
    )
  }
}
