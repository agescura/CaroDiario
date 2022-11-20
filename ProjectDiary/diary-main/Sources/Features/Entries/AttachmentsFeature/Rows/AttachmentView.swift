import SwiftUI
import ComposableArchitecture
import Models

public struct Attachment: ReducerProtocol {
  public init() {}
  
  public enum State: Equatable {
    case image(AttachmentImage.State)
    case video(AttachmentVideo.State)
    case audio(AttachmentAudio.State)
  }
  
  public enum Action: Equatable {
    case image(AttachmentImage.Action)
    case video(AttachmentVideo.Action)
    case audio(AttachmentAudio.Action)
  }
  
  public var body: some ReducerProtocolOf<Self> {
    Scope(state: /State.image, action: /Action.image) {
      AttachmentImage()
    }
    Scope(state: /State.video, action: /Action.video) {
      AttachmentVideo()
    }
    Scope(state: /State.audio, action: /Action.audio) {
      AttachmentAudio()
    }
  }
}

extension Attachment.State {
  public var url: URL {
    switch self {
    case let .image(state):
      return state.entryImage.url
    case let .video(state):
      return state.entryVideo.url
    case let .audio(state):
      return state.entryAudio.url
    }
  }
  
  public var thumbnail: URL? {
    switch self {
    case let .image(state):
      return state.entryImage.thumbnail
    case let .video(state):
      return state.entryVideo.thumbnail
    case .audio:
      return nil
    }
  }
  
  public var attachment: EntryAttachment {
    switch self {
    case let .image(value):
      return value.entryImage
    case let .video(value):
      return value.entryVideo
    case let .audio(value):
      return value.entryAudio
    }
  }
  
  public var date: Date {
    switch self {
    case let .image(value):
      return value.entryImage.lastUpdated
    case let .video(value):
      return value.entryVideo.lastUpdated
    case let .audio(value):
      return value.entryAudio.lastUpdated
    }
  }
}

extension Attachment.State: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case let .image(state):
      hasher.combine(state.entryImage.id)
    case let .video(state):
      hasher.combine(state.entryVideo.id)
    case let .audio(state):
      hasher.combine(state.entryAudio.id)
    }
  }
}

public struct AttachmentView: View {
  let store: StoreOf<Attachment>
  
  public var body: some View {
    SwitchStore(self.store) {
      CaseLet(
        state: /Attachment.State.image,
        action: Attachment.Action.image,
        then: AttachmentImageView.init(store:)
      )
      
      CaseLet(
        state: /Attachment.State.video,
        action: Attachment.Action.video,
        then: AttachmentVideoView.init(store:)
      )
      
      CaseLet(
        state: /Attachment.State.audio,
        action: Attachment.Action.audio,
        then: AttachmentAudioView.init(store:)
      )
    }
  }
}
