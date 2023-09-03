import SwiftUI
import ComposableArchitecture
import Views
import Models
import Localizables


public struct AttachmentVideo: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var entryVideo: EntryVideo
		
		public init(
			entryVideo: EntryVideo
		) {
			self.entryVideo = entryVideo
		}
	}
	
	public enum Action: Equatable {
		case presentVideoPlayer(Bool)
	}
	
	public var body: some ReducerOf<Self> {
		EmptyReducer()
	}
}

struct AttachmentVideoView: View {
	private let store: StoreOf<AttachmentVideo>
	
	public init(
		store: StoreOf<AttachmentVideo>
	) {
		self.store = store
	}
	
	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			ZStack {
				ImageView(url: viewStore.entryVideo.thumbnail)
					.frame(width: 52, height: 52)
				Image(systemName: "play.fill")
					.foregroundColor(.adaptiveWhite)
					.frame(width: 8, height: 8)
			}
			.onTapGesture {
				viewStore.send(.presentVideoPlayer(true))
			}
		}
	}
}

