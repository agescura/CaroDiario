import ComposableArchitecture
import Models

public struct AttachmentRowVideoDetailFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		let entryAudio: EntryAudio
		
		public init(
			entryAudio: EntryAudio
		) {
			self.entryAudio = entryAudio
		}
	}
	
	public enum Action: Equatable {
		
	}
	
	public var body: some ReducerProtocolOf<Self> {
		EmptyReducer()
	}
}
