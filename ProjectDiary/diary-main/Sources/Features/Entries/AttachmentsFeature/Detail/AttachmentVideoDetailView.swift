import ComposableArchitecture
import SwiftUI
import AVKit
import Models

public struct AttachmentVideoDetail: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var entryVideo: EntryVideo
		
		public init(
			attachment: AttachmentVideo.State
		) {
			self.entryVideo = attachment.entryVideo
		}
	}
	
	public enum Action: Equatable {}
	
	public var body: some ReducerOf<Self> {
		EmptyReducer()
	}
}

public struct AttachmentVideoDetailView: View {
	private let store: StoreOf<AttachmentVideoDetail>
	
	public init(
		store: StoreOf<AttachmentVideoDetail>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			VideoPlayer(player: AVPlayer(url: viewStore.entryVideo.url))
				.padding(.bottom, 32)
		}
	}
}
