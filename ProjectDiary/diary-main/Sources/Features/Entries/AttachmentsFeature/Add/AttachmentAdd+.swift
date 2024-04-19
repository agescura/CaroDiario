import Foundation
import Models

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
