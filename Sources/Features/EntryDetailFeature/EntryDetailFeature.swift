import ApplicationClient
import AVCaptureDeviceClient
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
  public let id: UUID
  public let pathUrl: String
  public let format: Format
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

extension EntryDetailFeature.Destination.State: Equatable, Sendable {}
extension EntryDetailFeature.Destination.Action: Equatable, Sendable {}

@Reducer
public struct EntryDetailFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable, Sendable {
    @FetchAll
    public var attachmentsRows: [Attachment]
    @Presents public var destination: Destination.State?
    public var entry: Entry.Draft
    public let entryOriginal: Entry.Draft
    public var isPhotoPickerPresented = false
    public var photosPickerItem: PhotosPickerItem?
    public var presentImagePicker: Bool = false
    
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
      destination: Destination.State? = nil,
      entry: Entry.Draft
		) {
      self.destination = destination
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
  
  @Reducer
  public enum Destination {
    case attachment(AttachmentFeature)
    case dialog(ConfirmationDialogState<Dialog>)
    
    public enum Dialog: Equatable, Sendable {
      case camera
      case photoPicker
    }
  }
	
	public enum Action: ViewAction, Equatable, BindableAction {
    case authorizationCameraResponse(AuthorizedVideoStatus)
    case destination(PresentationAction<Destination.Action>)
    case binding(BindingAction<State>)
    case entryResponse(Entry.Draft)
    case presentCameraPicker(Bool)
    case presentImagePicker(Bool)
    case storeImage(Data)
    case storeVideo(URL)
    case view(View)

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
  @Dependency(\.avCaptureDeviceClient) var avCaptureDeviceClient
  @Dependency(\.calendar) var calendar
  @Dependency(\.defaultDatabase) var database
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.date.now) var now
  @Dependency(\.fileClient) var fileClient
	
	public var body: some ReducerOf<Self> {
    BindingReducer()
		Reduce { state, action in
      switch action {
      case let .authorizationCameraResponse(status):
        switch status {
        case .notDetermined:
          return .run { [requestAccess = avCaptureDeviceClient.requestAccess] send in
            try await send(.authorizationCameraResponse(requestAccess() ? .authorized : .denied))
          }
        case .denied:
          print("denied")
          return .none
        case .authorized:
          return .send(.presentCameraPicker(true))
        case .restricted:
          print("restricted")
          return .none
        }
      case .destination(.presented(.dialog(.photoPicker))):
        state.destination = nil
        state.isPhotoPickerPresented = true
        return .none
      case .destination(.presented(.dialog(.camera))):
        return .run { [authorizationStatus = avCaptureDeviceClient.authorizationStatus] send in
          try await send(.authorizationCameraResponse(authorizationStatus()))
        }
      case .destination:
        return .none
      case .binding(\.photosPickerItem):
        guard let photosPickerItem = state.photosPickerItem else { return .none }
        state.photosPickerItem = nil
        
        return .run { send in
          guard
            let asset = try await photosPickerItem.loadTransferable(type: TransferableAsset.self),
            let source = asset.source
          else { return }
          
          switch source {
          case let .image(data):
            await send(.storeImage(data))
          case let .video(url):
            await send(.storeVideo(url))
          }
        }
      case .binding:
        return .none
      case let .entryResponse(entry):
        state.entry = entry
        return .none
      case let .presentCameraPicker(value), let .presentImagePicker(value):
//        state.addAttachmentInFlight = true
        
        state.presentImagePicker = value
//        state.presentImagePickerSource = .camera
        return .none
      case let .storeImage(data):
        return .run { [database, fileClient, id = state.entry.id, updateQuery = state.updateQuery] _ in
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
            guard let storedAsset, let entryID = id else { return }
            try EntryAsset
              .insert {
                EntryAsset.Draft(assetID: storedAsset.id, entryID: entryID)
              }
              .execute(db)
          }
          await updateQuery()
        }
      case let .storeVideo(url):
        return .run { [fileClient, database, id = state.entry.id, updateQuery = state.updateQuery] _ in
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
            guard let storedAsset, let entryID = id else { return }
            try EntryAsset
              .insert {
                EntryAsset.Draft(assetID: storedAsset.id, entryID: entryID)
              }
              .execute(db)
          }
          await updateQuery()
        }
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
          state.destination = .attachment(AttachmentFeature.State(attachment: attachment))
          return .none
        case .dialogButtonTapped:
          state.destination = .dialog(.attachments)
          return .none
        case .dismissButtonTapped:
          state.destination = nil
          return .none
        case .removeAttachmentButtonTapped:
          guard let attachment = state.destination?.attachment?.attachment else { return .none }
          state.destination = nil
          return .run { [database, fileClient, attachment] send in
            try await database.write { db in
              try Asset
                .find(attachment.id)
                .delete()
                .execute(db)
            }
            try await fileClient.removeAttachments([attachment.pathUrl])
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
    .ifLet(\.$destination, action: \.destination)
	}
}

extension ConfirmationDialogState where Action == EntryDetailFeature.Destination.Dialog {
	public static var attachments: Self {
		ConfirmationDialogState {
			TextState("AddEntry.ChooseOption".localized)
		} actions: {
			ButtonState(action: .camera, label: { TextState("AddEntry.Camera".localized) })
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
