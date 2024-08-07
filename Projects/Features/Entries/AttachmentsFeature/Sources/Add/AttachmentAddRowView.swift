import ComposableArchitecture
import Models
import SwiftUI

@Reducer
public struct AttachmentAddRow {
  public init() {}
  
	@ObservableState
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
    Scope(state: \.attachment, action: \.attachment) {
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
			store: self.store.scope(state: \.attachment, action: \.attachment)
    )
  }
}
