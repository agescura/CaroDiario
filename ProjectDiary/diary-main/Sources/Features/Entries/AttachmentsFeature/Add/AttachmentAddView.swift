import SwiftUI
import ComposableArchitecture
import Models
import AVAudioPlayerClient
import UIApplicationClient
import FileClient

extension AttachmentAdd.State {
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

public struct AttachmentAdd: ReducerProtocol {
	public init() {}
	
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
	
	public var body: some ReducerProtocolOf<Self> {
		Scope(state: /State.image, action: /Action.image) {
			AttachmentAddImage()
		}
		Scope(state: /State.video, action: /Action.video) {
			AttachmentAddVideo()
		}
		Scope(state: /State.audio, action: /Action.audio) {
			AttachmentAddAudio()
		}
	}
}

extension AttachmentAdd.State: Hashable {
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

public struct AttachmentAddView: View {
	private let store: StoreOf<AttachmentAdd>
	
	public init(
		store: StoreOf<AttachmentAdd>
	) {
		self.store = store
	}
	
	public var body: some View {
		SwitchStore(self.store) {
			CaseLet(
				state: /AttachmentAdd.State.image,
				action: AttachmentAdd.Action.image,
				then: AttachmentAddImageView.init
			)
			
			CaseLet(
				state: /AttachmentAdd.State.video,
				action: AttachmentAdd.Action.video,
				then: AttachmentAddVideoView.init
			)
			
			CaseLet(
				state: /AttachmentAdd.State.audio,
				action: AttachmentAdd.Action.audio,
				then: AttachmentAddAudioView.init
			)
		}
	}
}
