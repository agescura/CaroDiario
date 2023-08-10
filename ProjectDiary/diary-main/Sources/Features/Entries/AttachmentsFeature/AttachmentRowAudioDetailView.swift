import ComposableArchitecture
import SwiftUI

public struct AttachmentRowAudioDetailView: View {
	private let store: StoreOf<AttachmentRowAudioDetailFeature>
	
	public init(
		store: StoreOf<AttachmentRowAudioDetailFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		Text("Audio")
	}
}
