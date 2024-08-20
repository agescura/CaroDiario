import ComposableArchitecture
import Models
import SwiftUI

@Reducer
public struct AttachmentAdd {
  public init() {}
  
	@ObservableState
  public enum State: Equatable {
    case image(AttachmentAddImage.State)
    case video(AttachmentAddVideo.State)
    case audio(AttachmentAddAudio.State)
  }
  
  public enum Action: Equatable {
    case image(AttachmentAddImage.Action)
    case video(AttachmentAddVideo.Action)
    case audio(AttachmentAddAudio.Action)
  }
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.image, action: \.image) {
      AttachmentAddImage()
    }
    Scope(state: \.video, action: \.video) {
      AttachmentAddVideo()
    }
    Scope(state: \.audio, action: \.audio) {
      AttachmentAddAudio()
    }
  }
}

public struct AttachmentAddView: View {
  let store: StoreOf<AttachmentAdd>
  
  public var body: some View {
		switch self.store.state {
			case .image:
				if let store = self.store.scope(state: \.image, action: \.image) {
					AttachmentAddImageView(store: store)
				}
			case .video:
				if let store = self.store.scope(state: \.video, action: \.video) {
					AttachmentAddVideoView(store: store)
				}
			case .audio:
				if let store = self.store.scope(state: \.audio, action: \.audio) {
					AttachmentAddAudioView(store: store)
				}
		}
  }
}
