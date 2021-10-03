//
//  AddEntryView.swift
//  AddEntryFeature
//
//  Created by Albert Gil Escura on 25/6/21.
//

import SwiftUI
import ComposableArchitecture
import SharedModels
import SharedViews
import CoreDataClient
import FileClient
import ImagePickerFeature
import SharedLocalizables
import AVCaptureDeviceClient
import UIApplicationClient
import AttachmentsFeature
import AudioPickerFeature
import AVAudioRecorderClient
import AVAudioSessionClient
import AVAudioPlayerClient
import AudioRecordFeature
import AVAssetClient

public struct AddEntryState: Equatable {
    public var type: AccessType
    public var entry: Entry
    
    public var text: String = ""
    
    public var plusAttachamentActionSheet: ConfirmationDialogState<AddEntryAction>?
    public var presentImagePicker: Bool = false
    public var presentImagePickerSource: PickerSourceType = .photoAlbum
    public var presentAudioPicker: Bool = false
    
    public var deniedCameraAlert: AlertState<AddEntryAction>?
    public var attachments: IdentifiedArrayOf<AttachmentRowState> = []
    public var dismissAlert: AlertState<AddEntryAction>?
    
    public var addAttachmentInFlight: Bool = false
    
    public var audioRecordState: AudioRecordState?
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

extension AddEntryState.AccessType {
    
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

public enum AddEntryAction: Equatable {
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
    
    case attachments(id: UUID, action: AttachmentRowAction)
    case removeAttachmentResponse(UUID)
    
    case dismissAlertButtonTapped
    case cancelDismissAlert
    case removeDraftEntryDismissAlert
    
    case finishAddEntry
    
    case audioRecordAction(AudioRecordAction)
    case presentAudioRecord(Bool)
}

public struct AddEntryEnvironment {
    public let coreDataClient: CoreDataClient
    public let fileClient: FileClient
    public let avCaptureDeviceClient: AVCaptureDeviceClient
    public let applicationClient: UIApplicationClient
    public let avAudioSessionClient: AVAudioSessionClient
    public let avAudioPlayerClient: AVAudioPlayerClient
    public let avAudioRecorderClient: AVAudioRecorderClient
    public let avAssetClient: AVAssetClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    public let mainRunLoop: AnySchedulerOf<RunLoop>
    public let uuid: () -> UUID
    
    public init(
        coreDataClient: CoreDataClient,
        fileClient: FileClient,
        avCaptureDeviceClient: AVCaptureDeviceClient,
        applicationClient: UIApplicationClient,
        avAudioSessionClient: AVAudioSessionClient,
        avAudioPlayerClient: AVAudioPlayerClient,
        avAudioRecorderClient: AVAudioRecorderClient,
        avAssetClient: AVAssetClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>,
        mainRunLoop: AnySchedulerOf<RunLoop>,
        uuid: @escaping () -> UUID
    ) {
        self.coreDataClient = coreDataClient
        self.fileClient = fileClient
        self.avCaptureDeviceClient = avCaptureDeviceClient
        self.applicationClient = applicationClient
        self.avAudioSessionClient = avAudioSessionClient
        self.avAudioPlayerClient = avAudioPlayerClient
        self.avAudioRecorderClient = avAudioRecorderClient
        self.avAssetClient = avAssetClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
        self.mainRunLoop = mainRunLoop
        self.uuid = uuid
    }
}

public let addEntryReducer: Reducer<AddEntryState, AddEntryAction, AddEntryEnvironment> = .combine(
    
    attachmentReducer
        .pullback(
            state: \AttachmentRowState.attachment,
            action: /AttachmentRowAction.attachment,
            environment: { AttachmentEnvironment(
                fileClient: $0.fileClient,
                applicationClient: $0.applicationClient,
                avAudioPlayerClient: $0.avAudioPlayerClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue)
            }
        )
        .forEach(
            state: \AddEntryState.attachments,
            action: /AddEntryAction.attachments,
            environment: { AddEntryEnvironment(
                coreDataClient: $0.coreDataClient,
                fileClient: $0.fileClient,
                avCaptureDeviceClient: $0.avCaptureDeviceClient,
                applicationClient: $0.applicationClient,
                avAudioSessionClient: $0.avAudioSessionClient,
                avAudioPlayerClient: $0.avAudioPlayerClient,
                avAudioRecorderClient: $0.avAudioRecorderClient,
                avAssetClient: $0.avAssetClient,
                mainQueue: $0.mainQueue,
                backgroundQueue: $0.backgroundQueue,
                mainRunLoop: $0.mainRunLoop,
                uuid: $0.uuid)
            }
        ),
    
    audioRecordReducer
        .optional()
        .pullback(
            state: \AddEntryState.audioRecordState,
            action: /AddEntryAction.audioRecordAction,
            environment: { AudioRecordEnvironment(
                fileClient: $0.fileClient,
                applicationClient: $0.applicationClient,
                avAudioSessionClient: $0.avAudioSessionClient,
                avAudioPlayerClient: $0.avAudioPlayerClient,
                avAudioRecorderClient: $0.avAudioRecorderClient,
                mainQueue: $0.mainQueue,
                mainRunLoop: $0.mainRunLoop,
                uuid: $0.uuid)
            }
        ),
    
    .init { state, action, environment in
        switch action {
        
        case .onAppear:
            state.text = state.entry.text.message
            
            var attachments: IdentifiedArrayOf<AttachmentRowState> = []
            
            let entryAttachments = state.entry.attachments.compactMap { attachment -> AttachmentRowState? in
                if let detailState = attachment.detail {
                    return AttachmentRowState(id: attachment.id, attachment: detailState)
                }
                return nil
            }
            for attachment in entryAttachments {
                attachments.append(attachment)
            }
            state.attachments = attachments
            
            return .none
            
        case .createDraftEntry:
            return environment.coreDataClient.createDraft(state.entry)
                .fireAndForget()
            
        case .addButtonTapped:
            let entryText = EntryText(
                id: environment.uuid(),
                message: state.text,
                lastUpdated: environment.mainRunLoop.now.date
            )
            return .merge(
                environment.coreDataClient.updateMessage(entryText, state.entry)
                    .fireAndForget(),
                environment.coreDataClient.publishEntry(state.entry)
                    .fireAndForget()
            )
        
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
                    /*.default(.init("AddEntry.Audio".localized), action: .send(.presentAudioPicker(true))),*/
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
            return environment.avCaptureDeviceClient.authorizationStatus()
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(AddEntryAction.requestAuthorizationCameraResponse)
            
        case let .requestAuthorizationCameraResponse(response):
            switch response {
            case .notDetermined:
                return environment.avCaptureDeviceClient.requestAccess()
                    .map(AddEntryAction.requestAccessCameraResponse)
            case .denied:
                return Effect(value: .deniedCameraAlertButtonTapped)
            case .authorized:
                return Effect(value: AddEntryAction.presentCameraPicker(true))
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
            return environment.applicationClient.openSettings()
                .fireAndForget()
            
        case let .loadAttachment(response):
            switch response {
            case let .image(image):
                return Effect(value: AddEntryAction.loadImage(image))
            case let .video(url):
                return Effect(value: AddEntryAction.loadVideo(url))
            }
            
        case let .loadImage(image):
            let id = environment.uuid()
            let thumbnailId = environment.uuid()
            let path = environment.fileClient.path(id).appendingPathExtension("png")
            let thumbnail = environment.fileClient.path(thumbnailId).appendingPathExtension("png")
            
            let entryImage = EntryImage(
                id: id,
                lastUpdated: environment.mainRunLoop.now.date,
                thumbnail: thumbnail,
                url: path
            )
            
            return environment.fileClient.addImage(image, entryImage, environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(AddEntryAction.loadImageResponse)
            
        case let .loadImageResponse(entryImage):
            state.addAttachmentInFlight = false
            state.attachments.append(
                .init(id: entryImage.id, attachment: .image(.init(entryImage: entryImage)))
            )
            
            return environment.coreDataClient.addAttachmentEntry(entryImage, state.entry.id)
                .fireAndForget()
            
        case let .loadVideo(url):
            return environment.avAssetClient.generateThumbnail(url)
                .replaceError(with: UIImage())
                .eraseToEffect()
                .map({ AddEntryAction.generatedThumbnail(url, $0) })
            
        case let .generatedThumbnail(url, image):
            let pathExtension = url.pathExtension
            let id = environment.uuid()
            let thumbnailId = environment.uuid()
            let path = environment.fileClient.path(id).appendingPathExtension(url.pathExtension)
            let thumbnail = environment.fileClient.path(thumbnailId)
            
            let entryVideo = EntryVideo(
                id: id,
                lastUpdated: environment.mainRunLoop.now.date,
                thumbnail: thumbnail,
                url: path
            )
            
            return environment.fileClient.addVideo(url, image, entryVideo, environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(AddEntryAction.loadVideoResponse)
            
        case let .loadVideoResponse(entryVideo):
            state.addAttachmentInFlight = false
            state.attachments.append(
                .init(id: entryVideo.id, attachment: .video(.init(entryVideo: entryVideo)))
            )
            
            return environment.coreDataClient.addAttachmentEntry(entryVideo, state.entry.id)
                .fireAndForget()
            
        case let .loadAudio(url):
            let pathExtension = url.pathExtension
            let id = environment.uuid()
            let thumbnailId = environment.uuid()
            let path = environment.fileClient.path(id).appendingPathComponent(url.pathExtension)
            let thumbnail = environment.fileClient.path(thumbnailId)
            
            let entryAudio = EntryAudio(
                id: id,
                lastUpdated: environment.mainRunLoop.now.date,
                url: path)
            
            return environment.fileClient.addAudio(url, entryAudio, environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(AddEntryAction.loadAudioResponse)
            
        case let .loadAudioResponse(entryAudio):
            state.addAttachmentInFlight = false
            state.attachments.append(.init(id: entryAudio.id, attachment: .audio(.init(entryAudio: entryAudio))))
        
            return environment.coreDataClient.addAttachmentEntry(entryAudio, state.entry.id)
                .map({ AddEntryAction.presentAudioRecord(false) })
            
        case let .attachments(id: id, action: .attachment(.video(.remove))),
            let .attachments(id: id, action: .attachment(.image(.remove))):
            guard let attachmentState = state.attachments[id: id]?.attachment else {
                return .none
            }
            
            return environment.fileClient.removeAttachments(
                [attachmentState.thumbnail, attachmentState.url].compactMap { $0 },
                environment.backgroundQueue
            )
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map { _ in attachmentState.attachment.id }
                .map(AddEntryAction.removeAttachmentResponse)
            
        case let .removeAttachmentResponse(id):
            state.attachments.remove(id: id)
            
            return environment.coreDataClient.removeAttachmentEntry(id)
                .fireAndForget()
            
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
            return .merge(
                environment.fileClient.removeAttachments(state.entry.attachments.urls, environment.backgroundQueue)
                    .fireAndForget(),
                environment.coreDataClient.removeEntry(state.entry.id)
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map({AddEntryAction.finishAddEntry})
            )
            
        case .finishAddEntry:
            return .none
            
        case .audioRecordAction(.addAudio):
            guard let audioPath = state.audioRecordState?.audioPath else { return .none }
            
            let id = environment.uuid()
            let thumbnailId = environment.uuid()
            let thumbnail = environment.fileClient.path(thumbnailId)
            
            let entryAudio = EntryAudio(
                id: id,
                lastUpdated: environment.mainRunLoop.now.date,
                url: audioPath
            )
            return environment.fileClient.addAudio(audioPath, entryAudio, environment.backgroundQueue)
                .receive(on: environment.mainQueue)
                .eraseToEffect()
                .map(AddEntryAction.loadAudioResponse)
            
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
)

public struct AddEntryView: View {
    public let store: Store<AddEntryState, AddEntryAction>
    
    public init(
        store: Store<AddEntryState, AddEntryAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text(viewStore.type.title)
                        .adaptiveFont(.latoBold, size: 16)
                        .foregroundColor(.adaptiveBlack)
                    Spacer()
                    
                    if viewStore.type == .add {
                        Button(action: {
                            viewStore.send(.dismissAlertButtonTapped)
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.adaptiveBlack)
                        })
                    }
                }
                
                TextEditorView(
                    placeholder: "AddEntry.WriteSomething".localized,
                    text: viewStore.binding(
                        get: \.text,
                        send: AddEntryAction.textEditorChange)
                )
                
                if viewStore.attachments.count > 0 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 8) {
                            ForEachStore(
                                store.scope(
                                    state: \.attachments,
                                    action: AddEntryAction.attachments(id:action:)),
                                content: AttachmentRowView.init(store:)
                            )
                        }
                    }
                    .frame(height: 52)
                }
                
                HStack(spacing: 8) {
                    SecondaryButtonView(
                        label: {
                            Text(viewStore.type.finishTitle)
                                .adaptiveFont(.latoRegular, size: 10)
                                .foregroundColor(.chambray)
                        },
                        disabled: viewStore.text.isEmpty
                    ) {
                        viewStore.send(.addButtonTapped)
                    }
                    
                    SecondaryButtonView(
                        label: {
                            Image(systemName: "plus")
                                .resizable()
                                .foregroundColor(.chambray)
                                .frame(width: 16, height: 16)
                        },
                        inFlight: viewStore.addAttachmentInFlight
                    ) {
                        viewStore.send(.plusAttachamentActionSheetButtonTapped)
                    }
                    .frame(width: 56)
                    .confirmationDialog(
                        store.scope(state: \.plusAttachamentActionSheet),
                        dismiss: .dismissPlusActionSheet
                    )
                }
                .frame(height: 56)
            }
            .padding(24)
            .alert(
                store.scope(state: \.deniedCameraAlert),
                dismiss: .dismissDeniedCameraAlert
            )
            .alert(
                store.scope(state: \.dismissAlert),
                dismiss: .cancelDismissAlert
            )
            .fullScreenCover(isPresented: viewStore.binding(
                get: \.presentImagePicker,
                send: AddEntryAction.presentImagePicker
            )) {
                ImagePicker(
                    type: viewStore.presentImagePickerSource,
                    onImport: { response in
                        viewStore.send(.loadAttachment(response))
                    }
                )
                .edgesIgnoringSafeArea(.all)
            }
            .fullScreenCover(isPresented: viewStore.binding(get: \.presentAudioPicker, send: AddEntryAction.presentAudioPicker)) {
                AudioPicker { audio in
                    switch audio {
                    case let .audio(url):
                        viewStore.send(.loadAudio(url))
                    }
                }
            }
            .fullScreenCover(isPresented: viewStore.binding(get: \.presentAudioRecord, send: AddEntryAction.presentAudioRecord)) {
                IfLetStore(
                    store.scope(
                        state: { $0.audioRecordState },
                        action: AddEntryAction.audioRecordAction),
                    then: AudioRecordView.init(store:)
                )
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
