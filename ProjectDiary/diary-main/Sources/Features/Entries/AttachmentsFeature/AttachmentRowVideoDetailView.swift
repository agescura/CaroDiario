import ComposableArchitecture
import SwiftUI

public struct AttachmentRowVideoDetailView: View {
	private let store: StoreOf<AttachmentRowVideoDetailFeature>
	
	public init(
		store: StoreOf<AttachmentRowVideoDetailFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		Text("Video")
	}
}
