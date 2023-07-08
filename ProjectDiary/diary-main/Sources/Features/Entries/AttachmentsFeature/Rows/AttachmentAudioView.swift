import SwiftUI
import ComposableArchitecture
import Views
import Models

public struct AttachmentAudio: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var entryAudio: EntryAudio
		
		public init(
			entryAudio: EntryAudio
		) {
			self.entryAudio = entryAudio
		}
	}
	
	public enum Action: Equatable {
		case presentAudioFullScreen(Bool)
	}
	
	public var body: some ReducerProtocolOf<Self> {
		EmptyReducer()
	}
}

struct AttachmentAudioView: View {
	private let store: StoreOf<AttachmentAudio>
	
	public init(
		store: StoreOf<AttachmentAudio>
	) {
		self.store = store
	}
	
	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			Rectangle()
				.fill(Color.adaptiveGray)
				.frame(width: 52, height: 52)
				.overlay(
					Image(systemName: "waveform")
						.foregroundColor(.adaptiveWhite)
						.frame(width: 8, height: 8)
				)
				.onTapGesture {
					viewStore.send(.presentAudioFullScreen(true))
				}
		}
	}
}
