import Foundation
import ComposableArchitecture
import AVAssetClient
import BackgroundQueue
import AVAudioRecorderClient
import AVAudioSessionClient
import AVAudioPlayerClient
import AVCaptureDeviceClient
import UIApplicationClient
import AttachmentsFeature
import AudioPickerFeature
import AudioRecordFeature
import FileClient
import ImagePickerFeature
import Models
import UIKit

public struct AddEntry: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var type: AccessType
    public var entry: Entry
    public var text: String = ""
    public var plusAttachamentActionSheet: ConfirmationDialogState<Action>?
    public var presentImagePicker: Bool = false
    public var presentImagePickerSource: PickerSourceType = .photoAlbum
    public var presentAudioPicker: Bool = false
    public var deniedCameraAlert: AlertState<Action>?
    public var attachments: IdentifiedArrayOf<AttachmentAddRow.State> = []
    public var dismissAlert: AlertState<Action>?
    public var addAttachmentInFlight: Bool = false
    public var audioRecordState: AudioRecord.State?
    public var presentAudioRecord: Bool = false
    
    public enum AccessType {
      case add
      case edit
    }
    
    public init(
      type: AccessType,
      entry: Entry
    ) {
      self.type = type
      self.entry = entry
    }
  }
  
  public enum Action: Equatable {
    case onAppear
    case createDraftEntry
    case addButtonTapped
    case textEditorChange(String)
    case plusAttachamentActionSheetButtonTapped
    case dismissPlusActionSheet
    case presentImagePicker(Bool)
    case presentAudioPicker(Bool)
    case presentCameraPicker(Bool)
    case requestAuthorizationCamera
    case requestAuthorizationCameraResponse(AuthorizedVideoStatus)
    case requestAccessCameraResponse(Bool)
    case deniedCameraAlertButtonTapped
    case dismissDeniedCameraAlert
    case settingActionTappedDeniedCameraAlert
    case loadAttachment(PickerResponseType)
    case loadImage(UIImage)
    case loadImageResponse(EntryImage)
    case loadVideo(URL)
    case generatedThumbnail(URL, UIImage)
    case loadVideoResponse(EntryVideo)
    case loadAudio(URL)
    case loadAudioResponse(EntryAudio)
    case attachments(id: UUID, action: AttachmentAddRow.Action)
    case removeAttachmentResponse(UUID)
    case dismissAlertButtonTapped
    case cancelDismissAlert
    case removeDraftEntryDismissAlert
    case finishAddEntry
    case audioRecordAction(AudioRecord.Action)
    case presentAudioRecord(Bool)
  }
  
  @Dependency(\.uuid) private var uuid
  @Dependency(\.fileClient) private var fileClient
  @Dependency(\.mainQueue) private var mainQueue
  @Dependency(\.mainRunLoop.now.date) private var now
  @Dependency(\.backgroundQueue) private var backgroundQueue
  @Dependency(\.avCaptureDeviceClient) private var avCaptureDeviceClient
  @Dependency(\.avAssetClient) private var avAssetClient
  @Dependency(\.applicationClient) private var applicationClient
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .forEach(\.attachments, action: /Action.attachments) {
        AttachmentAddRow()
      }
      .ifLet(\.audioRecordState, action: /Action.audioRecordAction) {
        AudioRecord()
      }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action, Never> {
    switch action {
    case .onAppear:
      state.text = state.entry.text.message
      
      var attachments: IdentifiedArrayOf<AttachmentAddRow.State> = []
      
      let entryAttachments = state.entry.attachments.compactMap { attachment -> AttachmentAddRow.State? in
        if let detailState = attachment.addDetail {
          return AttachmentAddRow.State(id: attachment.id, attachment: detailState)
        }
        return nil
      }
      for attachment in entryAttachments {
        attachments.append(attachment)
      }
      state.attachments = attachments
      
      return .none
      
    case .createDraftEntry:
      return .none
      
    case .addButtonTapped:
      return .none
      
    case let .textEditorChange(text):
      state.text = text
      return .none
      
    case .plusAttachamentActionSheetButtonTapped:
      state.plusAttachamentActionSheet = .init(
        title: .init("AddEntry.ChooseOption".localized),
        buttons: [
          .cancel(.init("Cancel".localized), action: .send(.dismissPlusActionSheet)),
          .default(.init("AddEntry.Camera".localized), action: .send(.requestAuthorizationCamera)),
          .default(.init("AddEntry.Photos".localized), action: .send(.presentImagePicker(true))),
          .default(.init("Crear un audio"), action: .send(.presentAudioRecord(true)))
        ]
      )
      return .none
      
    case .dismissPlusActionSheet:
      state.plusAttachamentActionSheet = nil
      return .none
      
    case let .presentImagePicker(value):
      state.addAttachmentInFlight = true
      
      state.presentImagePicker = value
      state.presentImagePickerSource = .photoAlbum
      return .none
      
    case let .presentCameraPicker(value):
      state.addAttachmentInFlight = true
      
      state.presentImagePicker = value
      state.presentImagePickerSource = .camera
      return .none
      
    case let .presentAudioPicker(value):
      state.presentAudioPicker = value
      return .none
      
    case .requestAuthorizationCamera:
      return .run { send in
        await send(.requestAuthorizationCameraResponse(self.avCaptureDeviceClient.authorizationStatus()))
      }
      
    case let .requestAuthorizationCameraResponse(response):
      switch response {
      case .notDetermined:
        return .task {
          .requestAccessCameraResponse(await self.avCaptureDeviceClient.requestAccess())
        }
      case .denied:
        return Effect(value: .deniedCameraAlertButtonTapped)
      case .authorized:
        return Effect(value: .presentCameraPicker(true))
      case .restricted:
        return Effect(value: .deniedCameraAlertButtonTapped)
      }
      
    case let .requestAccessCameraResponse(granted):
      if granted {
        return Effect(value: .presentCameraPicker(true))
      } else {
        return Effect(value: .deniedCameraAlertButtonTapped)
      }
      
    case .deniedCameraAlertButtonTapped:
      state.deniedCameraAlert = .init(
        title: .init("Camera.Denied".localized),
        message: .init("Camera.Denied.Message".localized),
        primaryButton: .cancel(.init("Cancel".localized), action: .send(.dismissDeniedCameraAlert)),
        secondaryButton: .default(.init("Camera.Denied.GoSettings".localized), action: .send(.settingActionTappedDeniedCameraAlert))
      )
      return .none
      
    case .dismissDeniedCameraAlert:
      state.deniedCameraAlert = nil
      return .none
      
    case .settingActionTappedDeniedCameraAlert:
      return .fireAndForget { await self.applicationClient.openSettings() }
      
    case let .loadAttachment(response):
      switch response {
      case let .image(image):
        return Effect(value: Action.loadImage(image))
      case let .video(url):
        return Effect(value: Action.loadVideo(url))
      }
      
    case let .loadImage(image):
      let id = self.uuid()
      let thumbnailId = self.uuid()
      let path = self.fileClient.path(id).appendingPathExtension("png")
      let thumbnail = self.fileClient.path(thumbnailId).appendingPathExtension("png")
      
      let entryImage = EntryImage(
        id: id,
        lastUpdated: self.now,
        thumbnail: thumbnail,
        url: path
      )
      
      return self.fileClient.addImage(image, entryImage, self.backgroundQueue)
        .receive(on: self.mainQueue)
        .eraseToEffect()
        .map(Action.loadImageResponse)
      
    case let .loadImageResponse(entryImage):
      state.addAttachmentInFlight = false
      state.attachments.append(
        .init(id: entryImage.id, attachment: .image(.init(entryImage: entryImage)))
      )
      return .none
      
    case let .loadVideo(url):
      return .run { [url = url] send in
        let thumbnail = try await self.avAssetClient.generateThumbnail(url)
        await send(.generatedThumbnail(url, thumbnail))
      }
      
    case let .generatedThumbnail(url, image):
      let id = self.uuid()
      let thumbnailId = self.uuid()
      let path = self.fileClient.path(id).appendingPathExtension(url.pathExtension)
      let thumbnail = self.fileClient.path(thumbnailId)
      
      let entryVideo = EntryVideo(
        id: id,
        lastUpdated: self.now,
        thumbnail: thumbnail,
        url: path
      )
      
      return self.fileClient.addVideo(url, image, entryVideo, self.backgroundQueue)
        .receive(on: self.mainQueue)
        .eraseToEffect()
        .map(Action.loadVideoResponse)
      
    case let .loadVideoResponse(entryVideo):
      state.addAttachmentInFlight = false
      state.attachments.append(
        .init(id: entryVideo.id, attachment: .video(.init(entryVideo: entryVideo)))
      )
      return .none
      
    case let .loadAudio(url):
      let id = self.uuid()
      let path = self.fileClient.path(id).appendingPathComponent(url.pathExtension)
      
      let entryAudio = EntryAudio(
        id: id,
        lastUpdated: self.now,
        url: path)
      
      return self.fileClient.addAudio(url, entryAudio, self.backgroundQueue)
        .receive(on: self.mainQueue)
        .eraseToEffect()
        .map(Action.loadAudioResponse)
      
    case let .loadAudioResponse(entryAudio):
      state.addAttachmentInFlight = false
      state.attachments.append(.init(id: entryAudio.id, attachment: .audio(.init(entryAudio: entryAudio))))
      return Effect(value: Action.presentAudioRecord(false))
      
    case let .attachments(id: id, action: .attachment(.video(.remove))),
      let .attachments(id: id, action: .attachment(.image(.remove))),
      let .attachments(id: id, action: .attachment(.audio(.remove))):
      guard let attachmentState = state.attachments[id: id]?.attachment else {
        return .none
      }
      
      return self.fileClient.removeAttachments(
        [attachmentState.thumbnail, attachmentState.url].compactMap { $0 },
        self.backgroundQueue
      )
      .receive(on: self.mainQueue)
      .eraseToEffect()
      .map { _ in attachmentState.attachment.id }
      .map(Action.removeAttachmentResponse)
      
    case let .removeAttachmentResponse(id):
      state.attachments.remove(id: id)
      return .none
      
    case .attachments:
      return .none
      
    case .dismissAlertButtonTapped:
      if state.text.isEmpty && state.attachments.isEmpty {
        return Effect(value: .removeDraftEntryDismissAlert)
      }
      
      state.dismissAlert = .init(
        title: .init("AddEntry.Exit".localized),
        message: .init("AddEntry.Exit.Message".localized),
        primaryButton: .cancel(.init("Cancel".localized), action: .send(.cancelDismissAlert)),
        secondaryButton: .destructive(.init("AddEntry.Exit.Yes".localized), action: .send(.removeDraftEntryDismissAlert))
      )
      return .none
      
    case .cancelDismissAlert:
      state.dismissAlert = nil
      return .none
      
    case .removeDraftEntryDismissAlert:
      state.dismissAlert = nil
      return Effect(value: Action.finishAddEntry)
      
    case .finishAddEntry:
      return .none
      
    case .audioRecordAction(.addAudio):
      guard let audioPath = state.audioRecordState?.audioPath else { return .none }
      
      let id = self.uuid()
      
      let entryAudio = EntryAudio(
        id: id,
        lastUpdated: self.now,
        url: audioPath
      )
      return self.fileClient.addAudio(audioPath, entryAudio, self.backgroundQueue)
        .receive(on: self.mainQueue)
        .eraseToEffect()
        .map(Action.loadAudioResponse)
      
    case .audioRecordAction(.dismiss):
      state.presentAudioRecord = false
      state.audioRecordState = nil
      return .none
      
    case .audioRecordAction:
      return .none
      
    case let .presentAudioRecord(value):
      state.presentAudioRecord = value
      state.audioRecordState = value ? .init() : nil
      return .none
    }
  }
}

extension AddEntry.State.AccessType {
  var title: String {
    switch self {
    case .add:
      return "AddEntry.Title".localized
    case .edit:
      return "AddEntry.Edit".localized
    }
  }
  
  var finishTitle: String {
    switch self {
    case .add:
      return "AddEntry.Add".localized
    case .edit:
      return "AddEntry.Update".localized
    }
  }
}
