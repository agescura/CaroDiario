import SwiftUI
import ComposableArchitecture
import Models

@Reducer
public struct Attachment {
  public init() {}
  
	@ObservableState
  public enum State: Equatable, Hashable {
    case image(AttachmentImage.State)
    case video(AttachmentVideo.State)
    case audio(AttachmentAudio.State)
		
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
  
	public enum Action: Equatable {
    case image(AttachmentImage.Action)
    case video(AttachmentVideo.Action)
    case audio(AttachmentAudio.Action)
  }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.image, action: \.image) {
      AttachmentImage()
    }
    Scope(state: \.video, action: \.video) {
      AttachmentVideo()
    }
    Scope(state: \.audio, action: \.audio) {
      AttachmentAudio()
    }
  }
}

public struct AttachmentView: View {
  let store: StoreOf<Attachment>
  
  public var body: some View {
		switch store.state {
			case .image:
				if let store = store.scope(state: \.image, action: \.image) {
					AttachmentImageView(store: store)
				}
			case .video:
				if let store = store.scope(state: \.video, action: \.video) {
					AttachmentVideoView(store: store)
				}
			case .audio:
				if let store = store.scope(state: \.audio, action: \.audio) {
					AttachmentAudioView(store: store)
				}
		}
  }
}
