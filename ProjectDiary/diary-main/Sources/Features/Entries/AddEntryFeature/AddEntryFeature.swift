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

public struct AddEntryFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var destination: Destination.State?
		public var entry: Entry
		public var text: String = ""
		public var presentImagePicker: Bool = false
		public var presentImagePickerSource: PickerSourceType = .photoAlbum
		public var presentAudioPicker: Bool = false
		public var attachments: IdentifiedArrayOf<AttachmentAddRow.State> = []
		public var addAttachmentInFlight: Bool = false
		public var audioRecordState: AudioRecord.State?
		public var presentAudioRecord: Bool = false
		
		public init(
			entry: Entry
		) {
			self.entry = entry
		}
	}
	
	public enum Action: Equatable {
		case destination(PresentationAction<Destination.Action>)
		case onAppear
		case confirmationDialogButtonTapped
		case createDraftEntry
		case addButtonTapped
		case textEditorChange(String)
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
	
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.avAssetClient) private var avAssetClient
	@Dependency(\.avCaptureDeviceClient) private var avCaptureDeviceClient
	@Dependency(\.backgroundQueue) private var backgroundQueue
	@Dependency(\.fileClient) private var fileClient
	@Dependency(\.mainQueue) private var mainQueue
	@Dependency(\.mainRunLoop.now.date) private var now
	@Dependency(\.uuid) private var uuid
	
	public struct Destination: ReducerProtocol {
		public enum State: Equatable {
			case alert(AlertState<Action.Alert>)
			case audioRecord(AudioRecord.State)
			case confirmationDialog(ConfirmationDialogState<Action.Dialog>)
		}
		public enum Action: Equatable {
			case alert(Alert)
			case audioRecord(AudioRecord.Action)
			case confirmationDialog(Dialog)
			
			public enum Alert: Equatable {
				case settingActionTappedDeniedCameraAlert
				case removeDraftEntryDismissAlert
			}
			
			public enum Dialog: Equatable {
				case requestAuthorizationCamera
				case presentImagePicker(Bool)
				case presentAudioRecord(Bool)
			}
		}
		public var body: some ReducerProtocolOf<Self> {
			Scope(state: /State.alert, action: /Action.alert) {}
			Scope(state: /State.audioRecord, action: /Action.audioRecord) {
				AudioRecord()
			}
			Scope(state: /State.confirmationDialog, action: /Action.confirmationDialog) {}
		}
	}
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .destination:
					return .none
					
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
					
				case .confirmationDialogButtonTapped:
					state.destination = .confirmationDialog(.chooseOption)
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
					return self.avCaptureDeviceClient.authorizationStatus()
						.receive(on: self.mainQueue)
						.eraseToEffect()
						.map(AddEntryFeature.Action.requestAuthorizationCameraResponse)
					
				case let .requestAuthorizationCameraResponse(response):
					switch response {
						case .notDetermined:
							return .task {
								.requestAccessCameraResponse(await self.avCaptureDeviceClient.requestAccess())
							}
						case .denied:
							return .send(.deniedCameraAlertButtonTapped)
						case .authorized:
							return .send(.presentCameraPicker(true))
						case .restricted:
							return .send(.deniedCameraAlertButtonTapped)
					}
					
				case let .requestAccessCameraResponse(granted):
					if granted {
						return .send(.presentCameraPicker(true))
					} else {
						return .send(.deniedCameraAlertButtonTapped)
					}
					
				case .deniedCameraAlertButtonTapped:
					state.destination = .alert(.camera)
					return .none
					
				case .settingActionTappedDeniedCameraAlert:
					return .fireAndForget { await self.applicationClient.openSettings() }
					
				case let .loadAttachment(response):
					switch response {
						case let .image(image):
							return .send(.loadImage(image))
						case let .video(url):
							return .send(.loadVideo(url))
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
						.map(AddEntryFeature.Action.loadImageResponse)
					
				case let .loadImageResponse(entryImage):
					state.addAttachmentInFlight = false
					state.attachments.append(
						.init(id: entryImage.id, attachment: .image(.init(entryImage: entryImage)))
					)
					return .none
					
				case let .loadVideo(url):
					return self.avAssetClient.generateThumbnail(url)
						.replaceError(with: UIImage())
						.eraseToEffect()
						.map({ AddEntryFeature.Action.generatedThumbnail(url, $0) })
					
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
						.map(AddEntryFeature.Action.loadVideoResponse)
					
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
						.map(AddEntryFeature.Action.loadAudioResponse)
					
				case let .loadAudioResponse(entryAudio):
					state.addAttachmentInFlight = false
					state.attachments.append(.init(id: entryAudio.id, attachment: .audio(.init(entryAudio: entryAudio))))
					return .send(.presentAudioRecord(false))
					
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
					.map(AddEntryFeature.Action.removeAttachmentResponse)
					
				case let .removeAttachmentResponse(id):
					state.attachments.remove(id: id)
					return .none
					
				case .attachments:
					return .none
					
				case .dismissAlertButtonTapped:
					if state.text.isEmpty && state.attachments.isEmpty {
						return .send(.removeDraftEntryDismissAlert)
					}
					
					state.destination = .alert(.dismiss)
					return .none
					
				case .removeDraftEntryDismissAlert:
					return .send(.finishAddEntry)
					
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
						.map(AddEntryFeature.Action.loadAudioResponse)
					
				default:
					return .none
			}
		}
		.forEach(\.attachments, action: /Action.attachments) {
			AttachmentAddRow()
		}
		.ifLet(\.audioRecordState, action: /Action.audioRecordAction) {
			AudioRecord()
		}
		.ifLet(\.$destination, action: /Action.destination) {
			Destination()
		}
	}
}

extension ConfirmationDialogState where Action == AddEntryFeature.Destination.Action.Dialog {
	static var chooseOption: Self {
		ConfirmationDialogState {
			TextState("AddEntry.ChooseOption".localized)
		} actions: {
			ButtonState(role: .cancel) {
				TextState("Cancel".localized)
			}
			ButtonState(action: .requestAuthorizationCamera) {
				TextState("AddEntry.Camera".localized)
			}
			ButtonState(action: .presentImagePicker(true)) {
				TextState("AddEntry.Photos".localized)
			}
			ButtonState(action: .presentAudioRecord(true)) {
				TextState("Crear un audio")
			}
		}
	}
}

extension AlertState where Action == AddEntryFeature.Destination.Action.Alert {
	static var camera: Self {
		AlertState {
			TextState("Camera.Denied".localized)
		} actions: {
			ButtonState.cancel(TextState("Cancel".localized))
			ButtonState.default(
				TextState("Camera.Denied.GoSettings".localized),
				action: .send(.settingActionTappedDeniedCameraAlert)
			)
		} message: {
			TextState("Camera.Denied.Message".localized)
		}
	}
	
	static var dismiss: Self {
		AlertState {
			TextState("AddEntry.Exit".localized)
		} actions: {
			ButtonState.destructive(.init("AddEntry.Exit.Yes".localized), action: .send(.removeDraftEntryDismissAlert))
		} message: {
			TextState("AddEntry.Exit.Message".localized)
		}
	}
}
