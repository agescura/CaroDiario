import ComposableArchitecture
import Models
import SwiftUI

public struct AttachmentRowFeature: Reducer {
	public init() {}
	
	public struct State: Identifiable, Equatable, Hashable {
		public let id: UUID
		public var attachment: AttachmentAdd.State
		
		public init(
			id: UUID,
			attachment: AttachmentAdd.State
		) {
			self.id = id
			self.attachment = attachment
		}
	}
	
	public enum Action: Equatable {
		case attachment(AttachmentAdd.Action)
	}
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.attachment, action: /Action.attachment) {
			AttachmentAdd()
		}
	}
}

public struct AttachmentAddRowView: View {
	private let store: StoreOf<AttachmentRowFeature>
	
	public init(
		store: StoreOf<AttachmentRowFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		AttachmentAddView(
			store: store.scope(
				state: \.attachment,
				action: AttachmentRowFeature.Action.attachment
			)
		)
	}
}
