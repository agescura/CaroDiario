import ApplicationClient
import ComposableArchitecture
import FileClient
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
  let pathUrl: String
  let format: Format
}

extension Attachment {
  public var fileUrl: URL {
    URL.documentsDirectory.appending(path: pathUrl)
  }
  
  public var imagePreview: UIImage? {
    let asset = AVURLAsset(url: fileUrl)
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    
    let timestamp = CMTime(seconds: 2, preferredTimescale: 60)
    
    do {
      let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
      return UIImage(cgImage: imageRef)
    } catch let error as NSError {
      print("Image generation failed with error \(error)")
      return nil
    }
  }
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
      EntryAsset
        .group(by: \.id)
        .where { $0.entryID == entry.id }
        .join(Asset.all) { $0.assetID.eq($1.id) }
        .select { _, asset in
          Attachment.Columns(
            id: asset.id,
            pathUrl: asset.pathUrl,
            format: asset.format
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
    
    func updateQuery() async {
      _ = await withErrorReporting {
        try await $attachmentsRows.load(attachmentsQuery, animation: .custom)
      }
    }
	}
	
	public enum Action: ViewAction, Equatable, BindableAction {
    case attachment(PresentationAction<AttachmentFeature.Action>)
    case binding(BindingAction<State>)
		case dialog(PresentationAction<Dialog>)
    case entryResponse(Entry.Draft)
    case view(View)

		public enum Dialog: Equatable, Sendable {
			case photoPicker
		}

    public enum View: Equatable {
      case addEntryButtonTapped
      case attachmentButtonTapped(Attachment)
      case dialogButtonTapped
      case dismissButtonTapped
      case removeAttachmentButtonTapped
      case task
    }
	}
	
	@Dependency(\.applicationClient) var applicationClient
  @Dependency(\.calendar) var calendar
  @Dependency(\.defaultDatabase) var database
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.date.now) var now
  @Dependency(\.fileClient) var fileClient
	
	public var body: some ReducerOf<Self> {
    BindingReducer()
		Reduce { state, action in
      switch action {
      case .attachment:
        return .none
      case .binding(\.photosPickerItem):
        guard let photosPickerItem = state.photosPickerItem else { return .none }
        state.photosPickerItem = nil
        
        return .run { [fileClient, database, state = state] _ in
          guard
            let asset = try await photosPickerItem.loadTransferable(type: TransferableAsset.self),
            let source = asset.source
          else { return }
          
          switch source {
          case let .image(data):
            let pathUrl = UUID().uuidString + ".png"
            let folderUrl = "UserData/Images/"
            try await fileClient.addImage(.image(data, folderUrl, pathUrl))
            try await database.write { db in
              let storedAsset = try Asset
                .insert {
                  Asset.Draft(
                    pathUrl: folderUrl + pathUrl,
                    format: .image
                  )
                }
                .returning(\.self)
                .fetchOne(db)
              guard let storedAsset, let entryID = state.entry.id else { return }
              try EntryAsset
                .insert {
                  EntryAsset.Draft(assetID: storedAsset.id, entryID: entryID)
                }
                .execute(db)
            }
          case let .video(url):
            let pathUrl = UUID().uuidString + ".mp4"
            let folderUrl = "UserData/Videos/"
            try await fileClient.addVideo(.video(url, folderUrl, pathUrl))
            try await database.write { db in
              let storedAsset = try Asset
                .insert {
                  Asset.Draft(
                    pathUrl: folderUrl + pathUrl,
                    format: .video
                  )
                }
                .returning(\.self)
                .fetchOne(db)
              guard let storedAsset, let entryID = state.entry.id else { return }
              try EntryAsset
                .insert {
                  EntryAsset.Draft(assetID: storedAsset.id, entryID: entryID)
                }
                .execute(db)
            }
          }
          await state.updateQuery()
        }
      case .binding:
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
      case let .view(action):
        switch action {
        case .addEntryButtonTapped:
          state.entry.isDraft = false
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
        case let .attachmentButtonTapped(attachment):
          state.attachment = AttachmentFeature.State(attachment: attachment)
          return .none
        case .dialogButtonTapped:
          state.dialog = .dialog
          return .none
        case .dismissButtonTapped:
          state.attachment = nil
          state.dialog = nil
          return .none
        case .removeAttachmentButtonTapped:
          guard let attachment = state.attachment?.attachment else { return .none }
          state.attachment = nil
          return .run { [database, fileClient, attachment] send in
            try await database.write { db in
              try Asset
                .find(attachment.id)
                .delete()
                .execute(db)
            }
            let fileUrl = URL.documentsDirectory.appendingPathComponent(attachment.pathUrl)
            try await fileClient.removeAttachments([fileUrl])
          }
        case .task:
          return .run { [database, entry = state.entry] send in
            let storedEntry = try await database.write { db in
              /* delete previous draft entry if exist */
              try Entry
                .where { $0.isDraft }
                .delete()
                .execute(db)
              /* ---------- */
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

extension UIImage {
  private func rotateImage() -> UIImage {
    if (imageOrientation == UIImage.Orientation.up) {
      return self
    }
    UIGraphicsBeginImageContext(size)
    draw(in: CGRect(origin: .zero, size: size))
    let copy = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return copy!
  }
  
  func resized(for size: CGSize? = nil) -> UIImage {
    guard let size = size else {
      return rotateImage()
    }
    
    return UIGraphicsImageRenderer(size: size)
      .image { _ in
        rotateImage()
          .draw(in: CGRect(origin: .zero, size: size))
      }
  }
}

struct TransferableAsset: Transferable {
  enum Source {
    case image(Data)
    case video(URL)
  }
  let source: Source?
  
  enum TransferError: Error {
    case importFailed
  }
  
  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(importedContentType: .image) { data in
      TransferableAsset(source: .image(data))
    }
    FileRepresentation(importedContentType: .video) { data in
      TransferableAsset(source: .video(data.file))
    }
    FileRepresentation(importedContentType: .movie) { data in
      TransferableAsset(source: .video(data.file))
    }
    FileRepresentation(importedContentType: .mpeg4Movie) { data in
      TransferableAsset(source: .video(data.file))
    }
  }
}
