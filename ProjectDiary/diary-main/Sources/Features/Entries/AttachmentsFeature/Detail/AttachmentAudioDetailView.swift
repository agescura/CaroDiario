import ComposableArchitecture
import SwiftUI
import Models
import FileClient
import UIApplicationClient
import AVAudioPlayerClient
import SwiftHelper

public struct AttachmentAudioDetail: Reducer {
	public init() {}
	
	public struct State: Equatable {
		let entryAudio: EntryAudio
		
		var isPlaying: Bool = false
		var playerDuration: Double = 0
		var isPlayerDragging: Bool = false
		var isDragging = false
		var playerProgress: CGFloat = 0
		var playerProgressTime: Double = 0
		
		public init(
			attachment: AttachmentAudio.State
		) {
			self.entryAudio = attachment.entryAudio
		}
	}
	
	public enum Action: Equatable {
		case playButtonTapped
	}
	
	@Dependency(\.avAudioPlayerClient) private var avAudioPlayerClient
	
	private struct PlayerManagerId: Hashable {}
	private struct PlayerTimerId: Hashable {}
	
	public var body: some ReducerOf<Self> {
		Reduce(self.core)
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
			case .playButtonTapped:
				return .none
		}
	}
}

public struct AttachmentAudioDetailView: View {
	private let store: StoreOf<AttachmentAudioDetail>
	
	public init(
		store: StoreOf<AttachmentAudioDetail>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			
		}
	}
}
