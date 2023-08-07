import ComposableArchitecture
import SwiftUI

public struct AttachmentsView: View {
	let store: StoreOf<AttachmentsFeature>
	
	public init(
		store: StoreOf<AttachmentsFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store.actionless,
			observe: \.attachments.isEmpty
		) { viewStore in
			ScrollView(.horizontal, showsIndicators: false) {
				LazyHStack(spacing: 8) {
					ForEachStore(
						self.store.scope(
							state: \.attachments,
							action: AttachmentsFeature.Action.attachments
						),
						content: AttachmentAddRowView.init
					)
				}
			}
			.frame(height: viewStore.state ? 0.0 : 52)
		}
	}
}
