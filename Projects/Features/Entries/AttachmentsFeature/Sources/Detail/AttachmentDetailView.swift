import ComposableArchitecture
import SwiftUI

@Reducer
public struct AttachmentDetail {
  public init() {}
  
	@ObservableState
  public enum State: Equatable {
    case image(AttachmentImageDetail.State)
    case video(AttachmentVideoDetail.State)
    case audio(AttachmentAudioDetail.State)
    
    public init(row: AttachmentRow.State) {
      switch row.attachment {
      case let .image(attachmentImageState):
        self = .image(AttachmentImageDetail.State(attachment: attachmentImageState))
      case let .video(attachmentVideoState):
        self = .video(AttachmentVideoDetail.State(attachment: attachmentVideoState))
      case let .audio(attachmentAudioState):
        self = .audio(AttachmentAudioDetail.State(attachment: attachmentAudioState))
      }
    }
  }

  public enum Action: Equatable {
    case image(AttachmentImageDetail.Action)
    case video(AttachmentVideoDetail.Action)
    case audio(AttachmentAudioDetail.Action)
  }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.image, action: \.image) {
      AttachmentImageDetail()
    }
    Scope(state: \.video, action: \.video) {
      AttachmentVideoDetail()
    }
    Scope(state: \.audio, action: \.audio) {
      AttachmentAudioDetail()
    }
  }
}

public struct AttachmentDetailView: View {
  let store: StoreOf<AttachmentDetail>
  
  public init(
    store: StoreOf<AttachmentDetail>
  ) {
    self.store = store
  }
  
  public var body: some View {
		switch store.state {
			case .image:
				if let store = store.scope(state: \.image, action: \.image) {
					AttachmentImageDetailView(store: store)
				}
			case .video:
				if let store = store.scope(state: \.video, action: \.video) {
					AttachmentVideoDetailView(store: store)
				}
			case .audio:
				if let store = store.scope(state: \.audio, action: \.audio) {
					AttachmentAudioDetailView(store: store)
				}
		}
  }
}
