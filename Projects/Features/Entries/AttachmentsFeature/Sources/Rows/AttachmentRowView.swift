import SwiftUI
import ComposableArchitecture
import Models

public struct AttachmentRow: Reducer {
  public init() {}
  
  public struct State: Identifiable, Equatable, Hashable {
    public let id: UUID
    public var attachment: Attachment.State
    
    public init(
      id: UUID,
      attachment: Attachment.State
    ) {
      self.id = id
      self.attachment = attachment
    }
  }
  
  public enum Action: Equatable {
    case attachment(Attachment.Action)
  }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.attachment, action: /Action.attachment) {
      Attachment()
    }
  }
}


public struct AttachmentRowView: View {
    let store: StoreOf<AttachmentRow>
    
    public init(
        store: StoreOf<AttachmentRow>
    ) {
        self.store = store
    }
    
    public var body: some View {
        AttachmentView(
            store: store.scope(
                state: \.attachment,
                action: AttachmentRow.Action.attachment
            )
        )
    }
}
