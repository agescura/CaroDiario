import AttachmentsFeature
import AudioPickerFeature
import AudioRecordFeature
import AVAssetClient
import AVAudioPlayerClient
import AVAudioRecorderClient
import AVAudioSessionClient
import AVCaptureDeviceClient
import ComposableArchitecture
import FileClient
import Foundation
import ImagePickerFeature
import Models
import UIApplicationClient
import UIKit

@Reducer
public struct AddEntryFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		public var addAttachmentInFlight: Bool = false
		@Presents public var alert: AlertState<Action.Alert>?
		public var attachments: IdentifiedArrayOf<AttachmentAddRow.State> = []
		@Presents public var audioRecord: AudioRecordFeature.State?
		@Presents public var dialog: ConfirmationDialogState<Action.Dialog>?
		public var deniedCameraAlert: AlertState<Action>?
		public var dismissAlert: AlertState<Action>?
		public var entry: Entry
		public var presentAudioPicker: Bool = false
		public var presentImagePicker: Bool = false
		public var presentImagePickerSource: PickerSourceType = .photoAlbum
		public var presentAudioRecord: Bool = false
		public var text: String = ""
		
		public init(
			entry: Entry
		) {
			self.entry = entry
		}
	}
	
	public enum Action: Equatable {
		case addButtonTapped
		case alert(PresentationAction<Alert>)
		case attachments(IdentifiedActionOf<AttachmentAddRow>)
		case audioRecord(PresentationAction<AudioRecordFeature.Action>)
		case dialog(PresentationAction<Dialog>)
		case cancelDismissAlert
		case createDraftEntry
		case deniedCameraAlertButtonTapped
		case dismissAlertButtonTapped
		case dismissDeniedCameraAlert
		case finishAddEntry
		case generatedThumbnail(URL, UIImage)
		case onAppear
		case loadAttachment(PickerResponseType)
		case loadAudio(URL)
		case loadAudioResponse(EntryAudio)
		case loadImage(UIImage)
		case loadImageResponse(EntryImage)
		case loadVideo(URL)
		case loadVideoResponse(EntryVideo)
		case confirmationDialogButtonTapped
		case presentAudioRecord(Bool)
		case presentAudioPicker(Bool)
		case presentCameraPicker(Bool)
		case presentImagePicker(Bool)
		case removeAttachmentResponse(UUID)
		case removeDraftEntryDismissAlert
		case requestAccessCameraResponse(Bool)
		case requestAuthorizationCameraResponse(AuthorizedVideoStatus)
		case settingActionTappedDeniedCameraAlert
		case textEditorChange(String)
		
		public enum Alert: Equatable {
			case openSettings
			case removeDraft
		}
		public enum Dialog: Equatable {
			case presentImagePicker
			case presentAudioRecord
			case requestAuthorizationCamera
		}
	}
	
	@Dependency(\.applicationClient) var applicationClient
	@Dependency(\.avCaptureDeviceClient) var avCaptureDeviceClient
	@Dependency(\.avAssetClient) var avAssetClient
	@Dependency(\.fileClient) var fileClient
	@Dependency(\.mainQueue) var mainQueue
	@Dependency(\.mainRunLoop.now.date) var now
	@Dependency(\.uuid) var uuid
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .addButtonTapped:
					return .none
					
				case .alert:
					return .none
					
				case let .attachments(.element(id: id, action: .attachment(.video(.alert(.presented(.remove)))))),
					let .attachments(.element(id: id, action: .attachment(.image(.alert(.presented(.remove)))))),
					let .attachments(.element(id: id, action: .attachment(.audio(.remove)))):
					guard let attachmentState = state.attachments[id: id]?.attachment else {
						return .none
					}
					
					return .run { send in
						_ = await self.fileClient.removeAttachments([attachmentState.thumbnail, attachmentState.url].compactMap { $0 })
						await send(.removeAttachmentResponse(attachmentState.attachment.id))
					}
				case .attachments:
					return .none
					
				case .audioRecord(.presented(.addAudio)):
					guard let audioPath = state.audioRecord?.audioPath else { return .none }
					
					let id = self.uuid()
					
					let entryAudio = EntryAudio(
						id: id,
						lastUpdated: self.now,
						url: audioPath
					)
					
					return .run { send in
						await send(.loadAudioResponse(self.fileClient.addAudio(audioPath, entryAudio)))
					}
					
					//    case .audioRecordAction(.dismiss):
					//      state.presentAudioRecord = false
					//      state.audioRecordState = nil
					//      return .none
					
				case .audioRecord:
					return .none
					
				case let .dialog(.presented(confirmationDialogAction)):
					switch confirmationDialogAction {
						case .presentImagePicker:
							return .send(.presentAudioPicker(true))
						case .requestAuthorizationCamera:
							return .run { send in
								await send(.requestAuthorizationCameraResponse(self.avCaptureDeviceClient.authorizationStatus()))
							}
						case .presentAudioRecord:
							return .send(.presentAudioRecord(true))
					}
				case .dialog:
					return .none
					
				case .cancelDismissAlert:
					state.dismissAlert = nil
					return .none
					
				case .createDraftEntry:
					return .none
					
				case .deniedCameraAlertButtonTapped:
					state.alert = AlertState {
						TextState("Camera.Denied".localized)
					} actions: {
						ButtonState(role: .cancel, label: { TextState("Cancel".localized)})
						ButtonState(action: .openSettings, label: { TextState("Camera.Denied.GoSettings".localized)})
					} message: {
						TextState("Camera.Denied.Message".localized)
					}
					return .none
					
				case .dismissAlertButtonTapped:
					if state.text.isEmpty && state.attachments.isEmpty {
						return .send(.removeDraftEntryDismissAlert)
					}
					state.alert = AlertState {
						TextState("AddEntry.Exit".localized)
					} actions: {
						ButtonState(role: .cancel, label: { TextState("Cancel".localized)})
						ButtonState(action: .removeDraft, label: { TextState("AddEntry.Exit.Yes".localized)})
					} message: {
						TextState("AddEntry.Exit.Message".localized)
					}
					return .none
					
				case .dismissDeniedCameraAlert:
					state.deniedCameraAlert = nil
					return .none
					
				case .finishAddEntry:
					return .none
					
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
					
					return .run { send in
						await send(.loadVideoResponse(self.fileClient.addVideo(url, image, entryVideo)))
					}
					
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
					
				case let .loadAttachment(response):
					switch response {
						case let .image(image):
							return .send(Action.loadImage(image))
						case let .video(url):
							return .send(Action.loadVideo(url))
					}
					
				case let .loadAudio(url):
					let id = self.uuid()
					let path = self.fileClient.path(id).appendingPathComponent(url.pathExtension)
					
					let entryAudio = EntryAudio(
						id: id,
						lastUpdated: self.now,
						url: path)
					
					return .run { send in
						await send(.loadAudioResponse(self.fileClient.addAudio(url, entryAudio)))
					}
					
				case let .loadAudioResponse(entryAudio):
					state.addAttachmentInFlight = false
					state.attachments.append(.init(id: entryAudio.id, attachment: .audio(.init(entryAudio: entryAudio))))
					return .send(.presentAudioRecord(false))
					
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
					
					return .run { send in
						await send(.loadImageResponse(self.fileClient.addImage(image, entryImage)))
					}
					
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

				case let .loadVideoResponse(entryVideo):
					state.addAttachmentInFlight = false
					state.attachments.append(
						.init(id: entryVideo.id, attachment: .video(.init(entryVideo: entryVideo)))
					)
					return .none
					
				case .confirmationDialogButtonTapped:
					state.dialog = .attachments
					return .none
					
				case let .presentAudioRecord(value):
					state.presentAudioRecord = value
					state.audioRecord = value ? .init() : nil
					return .none
					
				case let .presentAudioPicker(value):
					state.presentAudioPicker = value
					return .none
					
				case let .presentCameraPicker(value):
					state.addAttachmentInFlight = true
					
					state.presentImagePicker = value
					state.presentImagePickerSource = .camera
					return .none
					
				case let .presentImagePicker(value):
					state.addAttachmentInFlight = true
					
					state.presentImagePicker = value
					state.presentImagePickerSource = .photoAlbum
					return .none
					
				case let .removeAttachmentResponse(id):
					state.attachments.remove(id: id)
					return .none
					
				case .removeDraftEntryDismissAlert:
					state.dismissAlert = nil
					return .send(Action.finishAddEntry)
					
				case let .requestAccessCameraResponse(granted):
					if granted {
						return .send(.presentCameraPicker(true))
					} else {
						return .send(.deniedCameraAlertButtonTapped)
					}
					
				case let .requestAuthorizationCameraResponse(response):
					switch response {
						case .notDetermined:
							return .run { send in
								await send(.requestAccessCameraResponse(self.avCaptureDeviceClient.requestAccess()))
							}
						case .denied:
							return .send(.deniedCameraAlertButtonTapped)
						case .authorized:
							return .send(.presentCameraPicker(true))
						case .restricted:
							return .send(.deniedCameraAlertButtonTapped)
					}
					
				case .settingActionTappedDeniedCameraAlert:
					return .run { _ in await self.applicationClient.openSettings() }
					
				case let .textEditorChange(text):
					state.text = text
					return .none
			}
		}
		.forEach(\.attachments, action: \.attachments) {
			AttachmentAddRow()
		}
		.ifLet(\.$alert, action: \.alert)
		.ifLet(\.$audioRecord, action:\.audioRecord) {
			AudioRecordFeature()
		}
		.ifLet(\.$dialog, action: \.dialog)
	}
}

public enum AccessType {
	case add
	case edit
}

extension AccessType {
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

extension ConfirmationDialogState where Action == AddEntryFeature.Action.Dialog {
	public static var attachments: Self {
		ConfirmationDialogState {
			TextState("AddEntry.ChooseOption".localized)
		} actions: {
			ButtonState(role: .cancel, label: { TextState("Cancel".localized) })
			ButtonState(action: .requestAuthorizationCamera, label: { TextState("AddEntry.Camera".localized) })
			ButtonState(action: .presentImagePicker, label: { TextState("AddEntry.Photos".localized) })
			ButtonState(action: .presentAudioRecord, label: { TextState("Crear un audio") })
		}
	}
}
