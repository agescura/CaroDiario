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
		@BindingState public var entry: Entry
		@BindingState public var presentImagePicker: Bool = false
		public var presentImagePickerSource: PickerSourceType = .photoAlbum
		@BindingState public var presentAudioPicker: Bool = false
		public var addAttachmentInFlight: Bool = false
		public var audioRecordPermission: AudioRecordPermission = .notDetermined
		
		public var attachments: AttachmentsFeature.State {
			get {
				AttachmentsFeature.State(
					entry: self.entry
				)
			}
			set {
				
			}
		}
		
		public init(
			entry: Entry
		) {
			self.entry = entry
		}
	}
	
	public enum Action: Equatable {
		case attachments(AttachmentsFeature.Action)
		case destination(PresentationAction<Destination.Action>)
		
		case createDraftEntry
		case presentAudioPicker(Bool)
		case presentCameraPicker(Bool)
		case requestAuthorizationCamera
		case requestAuthorizationCameraResponse(AuthorizedVideoStatus)
		case requestAccessCameraResponse(Bool)
		case deniedCameraAlertButtonTapped
		case dismissDeniedCameraAlert
		case settingActionTappedDeniedCameraAlert
		case loadImage(UIImage)
		case loadImageResponse(EntryImage)
		case loadVideo(URL)
		case generatedThumbnail(URL, UIImage)
		case loadVideoResponse(EntryVideo)
		case loadAudio(URL)
		case loadAudioResponse(EntryAudio)
		case removeAttachmentResponse(UUID)
		case dismissAlertButtonTapped
		case cancelDismissAlert
		case removeDraftEntryDismissAlert
		case finishAddEntry
		
		case view(View)
		
		public enum View: BindableAction, Equatable {
			case addButtonTapped
			case binding(BindingAction<State>)
			case confirmationDialogButtonTapped
			case dismiss
			case loadAttachment(PickerResponseType)
			case loadAudio(URL)
			case onAppear
		}
	}
	
	@Dependency(\.applicationClient) private var applicationClient
	@Dependency(\.avAudioSessionClient) private var avAudioSessionClient
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
			case audio(AttachmentRowAudioDetailFeature.State)
			case audioRecord(AudioRecordFeature.State)
			case confirmationDialog(ConfirmationDialogState<Action.Dialog>)
			case image(AttachmentRowImageDetailFeature.State)
		}
		public enum Action: Equatable {
			case alert(Alert)
			case audio(AttachmentRowAudioDetailFeature.Action)
			case audioRecord(AudioRecordFeature.Action)
			case confirmationDialog(Dialog)
			case image(AttachmentRowImageDetailFeature.Action)
			
			public enum Alert: Equatable {
				case confirmRemoveImageButtonTapped
				case removeDraftEntryDismissAlert
				case settingActionTappedDeniedCameraAlert
			}
			
			public enum Dialog: Equatable {
				case cameraButtonTapped
				case imagePickerButtonTapped
				case audioRecordButtonTapped
			}
		}
		public var body: some ReducerProtocolOf<Self> {
			Scope(state: /State.alert, action: /Action.alert) {}
			Scope(state: /State.audio, action: /Action.audio) {
				AttachmentRowAudioDetailFeature()
			}
			Scope(state: /State.audioRecord, action: /Action.audioRecord) {
				AudioRecordFeature()
			}
			Scope(state: /State.confirmationDialog, action: /Action.confirmationDialog) {}
			Scope(state: /State.image, action: /Action.image) {
				AttachmentRowImageDetailFeature()
			}
		}
	}
	
	public var body: some ReducerProtocolOf<Self> {
		BindingReducer(action: /Action.view)
		Scope(state: \.attachments, action: /Action.attachments) {
			AttachmentsFeature()
		}
		Reduce { state, action in
			switch action {
				case let .attachments(.attachments(id: id, action: .attachment(.audio(.audioButtonTapped)))):
					guard let entryAudio = state.entry.attachments.first(where: { $0.id == id }) as? EntryAudio else {
						return .none
					}
					state.destination = .audio(
						AttachmentRowAudioDetailFeature.State(entryAudio: entryAudio)
					)
					return .none
				case let .attachments(.attachments(id: id, action: .attachment(.image(.imageButtonTapped)))):
					guard let entryImage = state.entry.attachments.first(where: { $0.id == id }) as? EntryImage else {
						return .none
					}
					state.destination = .image(
						AttachmentRowImageDetailFeature.State(entryImage: entryImage)
					)
					return .none
				case let .view(viewAction):
					switch viewAction {
						case .addButtonTapped:
							return .none
							
						case .binding(.set(\.$presentImagePicker, true)):
							state.addAttachmentInFlight = true
							state.presentImagePicker = true
							state.presentImagePickerSource = .photoAlbum
							return .none
							
						case .binding:
							return .none
							
						case .confirmationDialogButtonTapped:
							state.destination = .confirmationDialog(.chooseOption)
							return .none
							
						case .dismiss:
							return .send(.destination(.dismiss))
							
						case let .loadAttachment(response):
							switch response {
								case let .image(image):
									return .send(.loadImage(image))
								case let .video(url):
									return .send(.loadVideo(url))
							}
							
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
							
						case .onAppear:
							state.audioRecordPermission = self.avAudioSessionClient.recordPermission()
							return .none
					}
					
				case .destination(.presented(.image(.alert(.presented(.removeButtonTapped))))):
					guard case let .image(imageDetailState) = state.destination,
							let index = state.entry.attachments.firstIndex(where: { $0.id == imageDetailState.entryImage.id })
					else { return .none }
					
					state.entry.attachments.remove(at: index)
					state.destination = nil
					return .none
					
				case .destination(.presented(.confirmationDialog(.cameraButtonTapped))):
					return .run { send in
						await send(.requestAuthorizationCameraResponse(self.avCaptureDeviceClient.authorizationStatus()))
					}
					
				case .destination(.presented(.confirmationDialog(.imagePickerButtonTapped))):
					state.addAttachmentInFlight = true
					state.presentImagePicker = true
					state.presentImagePickerSource = .photoAlbum
					return .none
					
				case .destination(.presented(.alert(.removeDraftEntryDismissAlert))):
					return .send(.removeDraftEntryDismissAlert)
					
				case .destination(.presented(.confirmationDialog(.audioRecordButtonTapped))):
					state.destination = .audioRecord(
						AudioRecordFeature.State(
							audioRecordPermission: state.audioRecordPermission
						)
					)
					return .none
					
				case let .destination(.presented(.audioRecord(.requestMicrophonePermissionResponse(authorized)))):
					state.audioRecordPermission = authorized ? .authorized : .denied
					return .none
					
				case .destination(.presented(.audioRecord(.dismiss))):
					state.destination = nil
					return .none
					
				case .destination(.presented(.audioRecord(.addAudio))):
					guard case let .audioRecord(audioRecordState) = state.destination,
							let audioPath = audioRecordState.audioPath else { return .none }
					
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
					
				case .destination:
					return .none
					
				case .createDraftEntry:
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
					return .none
					
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
					return .send(granted ? .presentCameraPicker(true) : .deniedCameraAlertButtonTapped)
					
				case .deniedCameraAlertButtonTapped:
					state.destination = .alert(.camera)
					return .none
					
				case .settingActionTappedDeniedCameraAlert:
					return .fireAndForget { await self.applicationClient.openSettings() }
					
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
					state.entry.attachments.append(entryImage)
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
					state.entry.attachments.append(entryVideo)
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
					state.entry.attachments.append(entryAudio)
					return .send(.destination(.dismiss))
					
//				case let .attachments(id: id, action: .attachment(.video(.remove))),
//					let .attachments(id: id, action: .attachment(.image(.remove))),
//					let .attachments(id: id, action: .attachment(.audio(.remove))):
//					guard let attachmentState = state.attachments[id: id]?.attachment else {
//						return .none
//					}
//					
//					return self.fileClient.removeAttachments(
//						[attachmentState.thumbnail, attachmentState.url].compactMap { $0 },
//						self.backgroundQueue
//					)
//					.receive(on: self.mainQueue)
//					.eraseToEffect()
//					.map { _ in attachmentState.attachment.id }
//					.map(AddEntryFeature.Action.removeAttachmentResponse)
					
				case let .removeAttachmentResponse(id):
//					state.attachments.remove(id: id)
					return .none
					
				case .dismissAlertButtonTapped:
					if state.entry.text.message.isEmpty && state.entry.attachments.isEmpty {
						return .send(.removeDraftEntryDismissAlert)
					}
					
					state.destination = .alert(.dismiss)
					return .none
					
				case .removeDraftEntryDismissAlert:
					return .send(.finishAddEntry)
					
				case .finishAddEntry:
					return .none
					
				default:
					return .none
			}
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
			ButtonState(action: .cameraButtonTapped) {
				TextState("AddEntry.Camera".localized)
			}
			ButtonState(action: .imagePickerButtonTapped) {
				TextState("AddEntry.Photos".localized)
			}
			ButtonState(action: .audioRecordButtonTapped) {
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
	
	static var remove: Self {
		AlertState {
			TextState("Image.Remove.Description".localized)
		} actions: {
			ButtonState.destructive(.init("Image.Remove.Title".localized), action: .send(.confirmRemoveImageButtonTapped))
		}
	}
}
