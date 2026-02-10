import ApplicationClient
import ComposableArchitecture
import Foundation
import Models
import Photos
import PhotosUI
import SQLiteData
import SwiftUI
import UIKit

@Selection
public struct Attachment: Sendable, Equatable, Hashable {
  let id: UUID
  let data: Data
  let format: String
}

@Reducer
public struct EntryDetailFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable, Sendable {
    @FetchAll
    public var attachmentsRows: [Attachment]
    @Presents public var attachment: AttachmentFeature.State?
		@Presents public var dialog: ConfirmationDialogState<Action.Dialog>?
    public var entry: Entry.Draft
    public let entryOriginal: Entry.Draft
    public var isPhotoPickerPresented = false
    public var photosPickerItem: PhotosPickerItem?
    
    private var attachmentsQuery: some StructuredQueries.Statement<Attachment> {
      Asset
        .select {
          Attachment.Columns(
            id: $0.id,
            data: $0.data,
            format: $0.format
          )
        }
    }
		
		public init(
      entry: Entry.Draft
		) {
			self.entry = entry
      self.entryOriginal = entry
      _attachmentsRows = FetchAll(
        attachmentsQuery,
        animation: .custom
      )
		}
	}
	
	public enum Action: Equatable, BindableAction {
    case addEntryButtonTapped
    case attachment(PresentationAction<AttachmentFeature.Action>)
    case attachmentButtonTapped(Attachment)
    case binding(BindingAction<State>)
    case dialogButtonTapped
		case dialog(PresentationAction<Dialog>)
    case dismissButtonTapped
    case entryResponse(Entry.Draft)
    case removeAttachmentButtonTapped
    case task

		public enum Dialog: Equatable, Sendable {
			case photoPicker
		}
	}
	
	@Dependency(\.applicationClient) var applicationClient
  @Dependency(\.calendar) var calendar
  @Dependency(\.defaultDatabase) var database
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.date.now) var now
	
	public var body: some ReducerOf<Self> {
    BindingReducer()
		Reduce { state, action in
      switch action {
      case .addEntryButtonTapped:
        withErrorReporting {
          try database.write { db in
            try Entry
              .upsert { state.entry }
              .execute(db)
          }
        }
        return .run { [dismiss] _ in
          await dismiss()
        }
      case .attachment:
        return .none
      case let .attachmentButtonTapped(attachment):
        state.attachment = AttachmentFeature.State(attachment: attachment)
        return .none
      case .binding(\.photosPickerItem):
        guard let photosPickerItem = state.photosPickerItem else { return .none }
        state.photosPickerItem = nil
        return .run { [database, entry = state.entry] _ in
          let data = try await photosPickerItem.loadTransferable(type: Data.self) ?? Data()
          let format = if UIImage(data: data) != nil {
            "image"
          } else {
            "video"
          }
          try await database.write { db in
            let storedAsset = try Asset
              .insert {
                Asset.Draft(
                  data: data,
                  format: format
                )
              }
              .returning(\.self)
              .fetchOne(db)
            guard let storedAsset, let entryID = entry.id else { return }
            try EntryAsset
              .insert {
                EntryAsset.Draft(assetID: storedAsset.id, entryID: entryID)
              }
              .execute(db)
          }
        }
      case .binding:
        return .none
      case .dialogButtonTapped:
        state.dialog = .dialog
        return .none
      case .dialog(.presented(.photoPicker)):
        state.dialog = nil
        state.isPhotoPickerPresented = true
        return .none
      case .dialog:
        return .none
      case let .entryResponse(entry):
        state.entry = entry
        return .none
      case .dismissButtonTapped:
        state.attachment = nil
        state.dialog = nil
        return .none
      case .removeAttachmentButtonTapped:
        guard let attachment = state.attachment?.attachment else { return .none }
        state.attachment = nil
        return .run { [database] send in
          try await database.write { db in
            try Asset
              .find(attachment.id)
              .delete()
              .execute(db)
          }
        }
      case .task:
        return .run { [database, entry = state.entry] send in
          let storedEntry = try await database.write { db in
            let storedEntry = try Entry
              .upsert { entry }
              .returning(\.self)
              .fetchOne(db)
            return storedEntry
          }
          guard let storedEntry else { return }
          await send(.entryResponse(Entry.Draft(storedEntry)))
        }
      }
		}
		.ifLet(\.$dialog, action: \.dialog)
    .ifLet(\.$attachment, action: \.attachment) {
      AttachmentFeature()
    }
	}
}

extension ConfirmationDialogState where Action == EntryDetailFeature.Action.Dialog {
	public static var dialog: Self {
		ConfirmationDialogState {
			TextState("AddEntry.ChooseOption".localized)
		} actions: {
			ButtonState(role: .cancel, label: { TextState("Cancel".localized) })
//			ButtonState(action: .requestAuthorizationCamera, label: { TextState("AddEntry.Camera".localized) })
			ButtonState(action: .photoPicker, label: { TextState("AddEntry.Photos".localized) })
//			ButtonState(action: .presentAudioRecord, label: { TextState("Crear un audio") })
		}
	}
}
