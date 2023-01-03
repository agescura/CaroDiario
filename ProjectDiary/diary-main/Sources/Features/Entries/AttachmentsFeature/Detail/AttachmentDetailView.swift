import ComposableArchitecture
import SwiftUI

public struct AttachmentDetail: ReducerProtocol {
  public init() {}
  
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
  
  public var body: some ReducerProtocolOf<Self> {
    Scope(state: /State.image, action: /Action.image) {
      AttachmentImageDetail()
    }
    Scope(state: /State.video, action: /Action.video) {
      AttachmentVideoDetail()
    }
    Scope(state: /State.audio, action: /Action.audio) {
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
    SwitchStore(self.store) {
      CaseLet(
        state: /AttachmentDetail.State.image,
        action: AttachmentDetail.Action.image,
        then: AttachmentImageDetailView.init(store:)
      )
      
      CaseLet(
        state: /AttachmentDetail.State.video,
        action: AttachmentDetail.Action.video,
        then: AttachmentVideoDetailView.init(store:)
      )
      
      CaseLet(
        state: /AttachmentDetail.State.audio,
        action: AttachmentDetail.Action.audio,
        then: AttachmentAudioDetailView.init(store:)
      )
    }
  }
}
