import ComposableArchitecture
import Foundation
import Models

public struct AttachmentsFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var attachments: IdentifiedArrayOf<AttachmentRowFeature.State> {
			get {
				IdentifiedArrayOf<AttachmentRowFeature.State>(
					uniqueElements: self.entry.attachments.compactMap { attachment -> AttachmentRowFeature.State? in
						if let detailState = attachment.addDetail {
							return AttachmentRowFeature.State(id: attachment.id, attachment: detailState)
						}
						return nil
					}
				)
			} set {
				
			}
		}
		public var entry: Entry
		
		public init(
			entry: Entry
		) {
			self.entry = entry
		}
	}
	
	public enum Action: Equatable {
		case attachments(id: UUID, action: AttachmentRowFeature.Action)
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .attachments:
					return .none
			}
		}
		.forEach(\.attachments, action: /Action.attachments) {
			AttachmentRowFeature()
		}
	}
}
