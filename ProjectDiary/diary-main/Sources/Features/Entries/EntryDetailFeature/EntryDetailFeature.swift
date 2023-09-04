import AddEntryFeature
import AttachmentsFeature
import AVAssetClient
import AVAudioRecorderClient
import AVCaptureDeviceClient
import AVAudioPlayerClient
import ComposableArchitecture
import CoreDataClient
import FileClient
import Foundation
import Models
import UIApplicationClient

public struct EntryDetailFeature: Reducer {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var destination: Destination.State?
		public var entry: Entry
		public var attachments: IdentifiedArrayOf<AttachmentRow.State> = []
		
		public var showAttachmentOverlayed = false
		public var seletedAttachmentRowState: AttachmentRow.State! = AttachmentRow.State(id: UUID(), attachment: .image(.init(entryImage: .init(id: UUID(), lastUpdated: .init(), thumbnail: URL(string: "www.google.es")!, url: URL(string: "www.google.es")!)))) {
			didSet {
				self.selectedAttachmentDetailState = AttachmentDetail.State(row: seletedAttachmentRowState)
			}
		}
		
		public var selectedAttachmentDetailState: AttachmentDetail.State! = AttachmentDetail.State(row: AttachmentRow.State(id: UUID(), attachment: .image(.init(entryImage: .init(id: UUID(), lastUpdated: .init(), thumbnail: URL(string: "www.google.es")!, url: URL(string: "www.google.es")!)))))
		
		public init(
			destination: Destination.State? = nil,
			entry: Entry
		) {
			self.destination = destination
			self.entry = entry
		}
		
		var message: String {
			entry.text.message
		}
	}
	
	public enum Action: Equatable {
		case onAppear
		case destination(PresentationAction<Destination.Action>)
		case entryResponse(Entry)
		case attachments(id: UUID, action: AttachmentRow.Action)
		case removeAttachmentResponse(UUID)
		
		case alertButtonTapped
		case confirmationDialogButtonTapped
		
		case selectedAttachmentRowAction(AttachmentRow.State)
		case dismissAttachmentOverlayed
		case attachmentDetail(AttachmentDetail.Action)
		case removeAttachment
		case processShareAttachment
	}
	
	public struct Destination: Reducer {
		public init() {}
		
		public enum State: Equatable {
			case alert(AlertState<Action.Alert>)
			case dialog(ConfirmationDialogState<Action.Dialog>)
			case edit(AddEntryFeature.State)
		}
		
		public enum Action: Equatable {
			case alert(Alert)
			case dialog(Dialog)
			case edit(AddEntryFeature.Action)
			
			public enum Alert: Equatable {
				case remove(Entry)
			}
			
			public enum Dialog: Equatable {
				case edit
				case share
			}
		}
		
		public var body: some ReducerOf<Self> {
			Scope(state: /State.alert, action: /Action.alert) {}
			Scope(state: /State.dialog, action: /Action.dialog) {}
			Scope(state: /State.edit, action: /Action.edit) {
				AddEntryFeature()
			}
		}
	}
	
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.fileClient) private var fileClient
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.selectedAttachmentDetailState, action: /Action.attachmentDetail) {
			AttachmentDetail()
		}
		Reduce { state, action in
			switch action {
				case let .attachments(id: id, action: .attachment(.image(.presentImageFullScreen(true)))),
					let .attachments(id: id, action: .attachment(.video(.presentVideoPlayer(true)))),
					let .attachments(id: id, action: .attachment(.audio(.presentAudioFullScreen(true)))):
					state.seletedAttachmentRowState = state.attachments[id: id]
					state.showAttachmentOverlayed = true
					self.applicationClient.showTabView(true)
					return .none
					
				case let .selectedAttachmentRowAction(selected):
					state.seletedAttachmentRowState = selected
					return .none
					
				case .dismissAttachmentOverlayed:
					state.showAttachmentOverlayed = false
					self.applicationClient.showTabView(false)
					return .none
					
				case .attachmentDetail:
					return .none
					
				case .destination(.presented(.edit(.view(.addButtonTapped)))):
					guard case let .edit(editState) = state.destination
					else { return .none }
					
					state.entry = editState.entry
					state.destination = nil
					return .none
					
				case .destination(.presented(.dialog(.edit))):
					state.destination = .edit(AddEntryFeature.State(entry: state.entry))
					return .none
					
				case .destination(.presented(.dialog(.share))):
					self.applicationClient.share(state.entry.text.message, .text)
					return .none
					
				case .destination:
					return .none
					
				case .processShareAttachment:
					let attachmentState = state.seletedAttachmentRowState.attachment
					
					self.applicationClient.share(attachmentState.url, .attachment)
					return .none
					
				case .onAppear:
					return .none
					
				case let .entryResponse(entry):
					state.entry = entry
					
					var attachments: IdentifiedArrayOf<AttachmentRow.State> = []
					
					let entryAttachments = state.entry.attachments.compactMap { attachment -> AttachmentRow.State? in
						if let detailState = attachment.detail {
							return AttachmentRow.State(id: attachment.id, attachment: detailState)
						}
						return nil
					}
						.sorted(by: { $0.attachment.date < $1.attachment.date })
					for attachment in entryAttachments {
						attachments.append(attachment)
					}
					state.attachments = attachments
					
					return .none
					
				case .removeAttachment:
					let attachmentState = state.seletedAttachmentRowState.attachment
					
					return .run { send in
						await self.fileClient.removeAttachments(
							[attachmentState.thumbnail, attachmentState.url].compactMap { $0 }
						)
						await send(.removeAttachmentResponse(attachmentState.attachment.id))
					}
					
				case let .removeAttachmentResponse(id):
					state.attachments.remove(id: id)
					return .send(.dismissAttachmentOverlayed)
					
				case .attachments:
					return .none
					
				case .confirmationDialogButtonTapped:
					state.destination = .dialog(
						ConfirmationDialogState {
							TextState("Entries.ChooseOption".localized)
						} actions: {
							ButtonState.cancel(TextState("Cancel".localized))
							ButtonState.default(TextState("Entries.Edit".localized), action: .send(.edit))
							ButtonState.default(TextState("Entries.Share".localized), action: .send(.share))
						}
					)
					return .none
					
				case .alertButtonTapped:
					state.destination = .alert(
						AlertState {
							TextState("Entries.Remove.Title".localized)
						} actions: {
							ButtonState.cancel(TextState("Cancel".localized))
							ButtonState.destructive(TextState("Entries.Remove.Action".localized), action: .send(.remove(state.entry)))
						}
					)
					return .none
			}
		}
		.ifLet(\.$destination, action: /Action.destination) {
			Destination()
		}
		.forEach(\.attachments, action: /Action.attachments) {
			AttachmentRow()
		}
	}
}
