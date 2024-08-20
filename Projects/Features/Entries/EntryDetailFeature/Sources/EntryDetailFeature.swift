import Foundation
import ComposableArchitecture
import Models
import AttachmentsFeature
import AddEntryFeature
import UIApplicationClient
import FileClient

public struct EntryDetailFeature: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var addEntryState: AddEntryFeature.State?
		@PresentationState public var alert: AlertState<Action.Alert>?
		public var attachments: IdentifiedArrayOf<AttachmentRow.State> = []
		@PresentationState public var confirmationDialog: ConfirmationDialogState<Action.Dialog>?
		public var entry: Entry
		public var meatballActionSheet: ConfirmationDialogState<Action>?
		public var presentAddEntry = false
		public var selectedAttachmentDetailState: AttachmentDetail.State! = AttachmentDetail.State(row: AttachmentRow.State(id: UUID(), attachment: .image(.init(entryImage: .init(id: UUID(), lastUpdated: .init(), thumbnail: URL(string: "www.google.es")!, url: URL(string: "www.google.es")!)))))
		public var seletedAttachmentRowState: AttachmentRow.State! = AttachmentRow.State(id: UUID(), attachment: .image(.init(entryImage: .init(id: UUID(), lastUpdated: .init(), thumbnail: URL(string: "www.google.es")!, url: URL(string: "www.google.es")!)))) {
			didSet {
				self.selectedAttachmentDetailState = AttachmentDetail.State(row: seletedAttachmentRowState)
			}
		}
		public var showAttachmentOverlayed = false
		
		public init(
			entry: Entry
		) {
			self.entry = entry
		}
		
		var message: String {
			entry.text.message
		}
	}
	
	@CasePathable
	public enum Action: Equatable {
		case addEntryAction(AddEntryFeature.Action)
		case alert(PresentationAction<Alert>)
		case alertRemoveButtonTapped
		case attachmentDetail(AttachmentDetail.Action)
		case attachments(id: UUID, action: AttachmentRow.Action)
		case confirmationDialog(PresentationAction<Dialog>)
		case dismissAttachmentOverlayed
		case dismissMeatballActionSheet
		case entryResponse(Entry)
		case meatballActionSheetButtonTapped
		case onAppear
		case presentAddEntry(Bool)
		case presentAddEntryCompleted
		case processShare
		case processShareAttachment
		case removeAttachment
		case removeAttachmentResponse(UUID)
		case selectedAttachmentRowAction(AttachmentRow.State)
		
		public enum Alert: Equatable {
			case remove(Entry)
		}
		public enum Dialog: Equatable {
			case presentAddEntry
			case processShare
		}
	}
	
	@Dependency(\.applicationClient) var applicationClient
	@Dependency(\.fileClient) var fileClient
	@Dependency(\.mainQueue) var mainQueue
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.selectedAttachmentDetailState, action: \.attachmentDetail) {
			AttachmentDetail()
		}
		Reduce { state, action in
			switch action {
				case .addEntryAction(.addButtonTapped):
					state.presentAddEntry = false
					state.addEntryState = nil
					return .send(.onAppear)
				case .addEntryAction(.finishAddEntry):
					state.presentAddEntry = false
					return .none
				case .addEntryAction:
					return .none
					
				case .alert:
					return .none
					
				case .alertRemoveButtonTapped:
					state.meatballActionSheet = nil
					state.alert = AlertState {
						TextState("Entries.Remove.Title".localized)
					} actions: {
						ButtonState(role: .cancel) { TextState("Cancel".localized) }
						ButtonState(role: .destructive, action: .remove(state.entry)) { TextState("Entries.Remove.Action".localized) }
					}
					return .none
					
				case .attachmentDetail:
					return .none
					
				case let .attachments(id: id, action: .attachment(.image(.presentImageFullScreen(true)))),
					let .attachments(id: id, action: .attachment(.video(.presentVideoPlayer(true)))),
					let .attachments(id: id, action: .attachment(.audio(.presentAudioFullScreen(true)))):
					state.seletedAttachmentRowState = state.attachments[id: id]
					state.showAttachmentOverlayed = true
					self.applicationClient.showTabView(true)
					return .none
				case .attachments:
					return .none
					
				case let .confirmationDialog(.presented(confirmationDialogActions)):
					switch confirmationDialogActions {
						case .presentAddEntry:
							return .send(.presentAddEntry(true))
						case .processShare:
							return .send(.processShare)
					}
				case .confirmationDialog:
					return .none
					
				case .dismissAttachmentOverlayed:
					state.showAttachmentOverlayed = false
					self.applicationClient.showTabView(false)
					return .none
					
				case .dismissMeatballActionSheet:
					state.meatballActionSheet = nil
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
					
				case .meatballActionSheetButtonTapped:
					state.confirmationDialog = ConfirmationDialogState {
						TextState("Entries.ChooseOption".localized)
					} actions: {
						ButtonState(role: .cancel, label: { TextState("Cancel".localized) })
						ButtonState(action: .presentAddEntry, label: { TextState("Entries.Edit".localized) })
						ButtonState(action: .processShare, label: { TextState("Entries.Share".localized) })
					}
					return .none
					
				case .onAppear:
					return .none
					
				case .presentAddEntry(true):
					state.presentAddEntry = true
					state.addEntryState = AddEntryFeature.State(entry: state.entry)
					return .none
					
				case .presentAddEntry(false):
					state.presentAddEntry = false
					return .run { send in
						try await self.mainQueue.sleep(for: .seconds(0.3))
						await send(.presentAddEntryCompleted)
					}
					
				case .presentAddEntryCompleted:
					state.addEntryState = nil
					return .send(.onAppear)
					
				case .processShare:
					self.applicationClient.share(state.entry.text.message, .text)
					return .none
					
				case .processShareAttachment:
					let attachmentState = state.seletedAttachmentRowState.attachment
					self.applicationClient.share(attachmentState.url, .attachment)
					return .none
					
				case .removeAttachment:
					let attachmentState = state.seletedAttachmentRowState.attachment
					
					return .run { send in
						_ = await self.fileClient.removeAttachments([attachmentState.thumbnail, attachmentState.url].compactMap { $0 })
						await send(.removeAttachmentResponse(attachmentState.attachment.id))
					}
					
				case let .removeAttachmentResponse(id):
					state.attachments.remove(id: id)
					return .send(.dismissAttachmentOverlayed)
					
				case let .selectedAttachmentRowAction(selected):
					state.seletedAttachmentRowState = selected
					return .none
			}
		}
		.forEach(\.attachments, action: /Action.attachments) {
			AttachmentRow()
		}
		.ifLet(\.$alert, action: \.alert)
		.ifLet(\.addEntryState, action: \.addEntryAction) {
			AddEntryFeature()
		}
	}
}

