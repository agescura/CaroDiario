import SwiftUI
import ComposableArchitecture
import Combine
import Models
import CoreDataClient
import FileClient
import Views
import AVCaptureDeviceClient
import UIApplicationClient
import AttachmentsFeature
import AddEntryFeature
import AVAudioSessionClient
import AVAudioPlayerClient
import AVAudioRecorderClient
import AVAssetClient
import UIApplicationClient

public struct EntryDetailState: Equatable {
  public var entry: Entry
  public var attachments: IdentifiedArrayOf<AttachmentRowState> = []
  
  public var meatballActionSheet: ConfirmationDialogState<EntryDetailAction>?
  public var removeAlert: AlertState<EntryDetailAction>?
  
  public var addEntryState: AddEntryState?
  public var presentAddEntry = false
  
  public var showAttachmentOverlayed = false
  public var seletedAttachmentRowState: AttachmentRowState! = AttachmentRowState(id: UUID(), attachment: .image(.init(entryImage: .init(id: UUID(), lastUpdated: .init(), thumbnail: URL(string: "www.google.es")!, url: URL(string: "www.google.es")!)))) {
    didSet {
      self.selectedAttachmentDetailState = AttachmentDetail.State(row: seletedAttachmentRowState)
    }
  }
  
  public var selectedAttachmentDetailState: AttachmentDetail.State! = AttachmentDetail.State(row: AttachmentRowState(id: UUID(), attachment: .image(.init(entryImage: .init(id: UUID(), lastUpdated: .init(), thumbnail: URL(string: "www.google.es")!, url: URL(string: "www.google.es")!)))))
  
  public init(
    entry: Entry
  ) {
    self.entry = entry
  }
  
  var message: String {
    entry.text.message
  }
}

public enum EntryDetailAction: Equatable {
  case onAppear
  case entryResponse(Entry)
  
  case attachments(id: UUID, action: AttachmentRowAction)
  case removeAttachmentResponse(UUID)
  
  case meatballActionSheetButtonTapped
  case dismissMeatballActionSheet
  
  case alertRemoveButtonTapped
  case dismissRemoveAlert
  case remove(Entry)
  
  case addEntryAction(AddEntryAction)
  case presentAddEntry(Bool)
  case presentAddEntryCompleted
  
  case processShare
  
  case selectedAttachmentRowAction(AttachmentRowState)
  case dismissAttachmentOverlayed
  case attachmentDetail(AttachmentDetail.Action)
  case removeAttachment
  case processShareAttachment
}

public struct EntryDetailEnvironment {
  public let fileClient: FileClient
  public let avCaptureDeviceClient: AVCaptureDeviceClient
  public let applicationClient: UIApplicationClient
  public let avAudioSessionClient: AVAudioSessionClient
  public let avAudioPlayerClient: AVAudioPlayerClient
  public let avAudioRecorderClient: AVAudioRecorderClient
  public let avAssetClient: AVAssetClient
  public let mainQueue: AnySchedulerOf<DispatchQueue>
  public let backgroundQueue: AnySchedulerOf<DispatchQueue>
  public let date: () -> Date
  public let uuid: () -> UUID
  
  public init(
    fileClient: FileClient,
    avCaptureDeviceClient: AVCaptureDeviceClient,
    applicationClient: UIApplicationClient,
    avAudioSessionClient: AVAudioSessionClient,
    avAudioPlayerClient: AVAudioPlayerClient,
    avAudioRecorderClient: AVAudioRecorderClient,
    avAssetClient: AVAssetClient,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    date: @escaping () -> Date,
    uuid: @escaping () -> UUID
  ) {
    self.fileClient = fileClient
    self.avCaptureDeviceClient = avCaptureDeviceClient
    self.applicationClient = applicationClient
    self.avAudioSessionClient = avAudioSessionClient
    self.avAudioPlayerClient = avAudioPlayerClient
    self.avAudioRecorderClient = avAudioRecorderClient
    self.avAssetClient = avAssetClient
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
    self.date = date
    self.uuid = uuid
  }
}

public let entryDetailReducer: Reducer<
  EntryDetailState,
  EntryDetailAction,
  EntryDetailEnvironment
> = .combine(
  attachmentReducer
    .pullback(
      state: \AttachmentRowState.attachment,
      action: /AttachmentRowAction.attachment,
      environment: { _ in ()
      }
    )
    .forEach(
      state: \EntryDetailState.attachments,
      action: /EntryDetailAction.attachments,
      environment: { EntryDetailEnvironment(
        fileClient: $0.fileClient,
        avCaptureDeviceClient: $0.avCaptureDeviceClient,
        applicationClient: $0.applicationClient,
        avAudioSessionClient: $0.avAudioSessionClient,
        avAudioPlayerClient: $0.avAudioPlayerClient,
        avAudioRecorderClient: $0.avAudioRecorderClient,
        avAssetClient: $0.avAssetClient,
        mainQueue: $0.mainQueue,
        backgroundQueue: $0.backgroundQueue,
        date: $0.date,
        uuid: UUID.init)
      }
    ),
  AnyReducer(
    Scope(state: \EntryDetailState.selectedAttachmentDetailState, action: /EntryDetailAction.attachmentDetail) {
      AttachmentDetail()
    }
  ),
  addEntryReducer
    .optional()
    .pullback(
      state: \EntryDetailState.addEntryState,
      action: /EntryDetailAction.addEntryAction,
      environment: { AddEntryEnvironment(
        fileClient: $0.fileClient,
        avCaptureDeviceClient: $0.avCaptureDeviceClient,
        applicationClient: $0.applicationClient,
        avAudioSessionClient: $0.avAudioSessionClient,
        avAudioPlayerClient: $0.avAudioPlayerClient,
        avAudioRecorderClient: $0.avAudioRecorderClient,
        avAssetClient: $0.avAssetClient,
        mainQueue: $0.mainQueue,
        backgroundQueue: $0.backgroundQueue,
        date: $0.date,
        uuid: $0.uuid)
      }
    ),
  .init { state, action, environment in
    switch action {
    case let .attachments(id: id, action: .attachment(.image(.presentImageFullScreen(true)))),
      let .attachments(id: id, action: .attachment(.video(.presentVideoPlayer(true)))),
      let .attachments(id: id, action: .attachment(.audio(.presentAudioFullScreen(true)))):
      state.seletedAttachmentRowState = state.attachments[id: id]
      state.showAttachmentOverlayed = true
      return environment.applicationClient.showTabView(true)
        .fireAndForget()
      
    case let .selectedAttachmentRowAction(selected):
      state.seletedAttachmentRowState = selected
      return .none
      
    case .dismissAttachmentOverlayed:
      state.showAttachmentOverlayed = false
      return environment.applicationClient.showTabView(false)
        .fireAndForget()
      
    case .attachmentDetail:
      return .none
      
    case .processShareAttachment:
      let attachmentState = state.seletedAttachmentRowState.attachment
      
      return environment.applicationClient.share(attachmentState.url, .attachment)
        .fireAndForget()
      
    case .onAppear:
      return .none
      
    case let .entryResponse(entry):
      state.entry = entry
      
      var attachments: IdentifiedArrayOf<AttachmentRowState> = []
      
      let entryAttachments = state.entry.attachments.compactMap { attachment -> AttachmentRowState? in
        if let detailState = attachment.detail {
          return AttachmentRowState(id: attachment.id, attachment: detailState)
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
      
      return environment.fileClient.removeAttachments(
        [attachmentState.thumbnail, attachmentState.url].compactMap { $0 },
        environment.backgroundQueue
      )
      .receive(on: environment.mainQueue)
      .eraseToEffect()
      .map { _ in attachmentState.attachment.id }
      .map(EntryDetailAction.removeAttachmentResponse)
      
    case let .removeAttachmentResponse(id):
      state.attachments.remove(id: id)
      return Effect(value: .dismissAttachmentOverlayed)
      
    case .attachments:
      return .none
      
    case .meatballActionSheetButtonTapped:
      state.meatballActionSheet = .init(
        title: .init("Entries.ChooseOption".localized),
        buttons: [
          .cancel(.init("Cancel".localized)),
          .default(.init("Entries.Edit".localized), action: .send(.presentAddEntry(true))),
          .default(.init("Entries.Share".localized), action: .send(.processShare))
        ])
      return .none
      
    case .dismissMeatballActionSheet:
      state.meatballActionSheet = nil
      return .none
      
    case .alertRemoveButtonTapped:
      state.meatballActionSheet = nil
      state.removeAlert = .init(
        title: .init("Entries.Remove.Title".localized),
        primaryButton: .cancel(.init("Cancel".localized), action: .send(.dismissRemoveAlert)),
        secondaryButton: .destructive(.init("Entries.Remove.Action".localized), action: .send(.remove(state.entry)))
      )
      return .none
      
    case .dismissRemoveAlert:
      state.removeAlert = nil
      return .none
      
    case .remove:
      return .none
      
    case .addEntryAction(.addButtonTapped):
      state.presentAddEntry = false
      state.addEntryState = nil
      return Effect(value: .onAppear)
      
    case .addEntryAction(.finishAddEntry):
      state.presentAddEntry = false
      return .none
      
    case .addEntryAction:
      return .none
      
    case .presentAddEntry(true):
      state.presentAddEntry = true
      state.addEntryState = .init(type: .edit, entry: state.entry)
      return .none
      
    case .presentAddEntry(false):
      state.presentAddEntry = false
      return Effect(value: .presentAddEntryCompleted)
        .delay(for: 0.3, scheduler: environment.mainQueue)
        .eraseToEffect()
      
    case .presentAddEntryCompleted:
      state.addEntryState = nil
      return Effect(value: .onAppear)
      
    case .processShare:
      return environment.applicationClient.share(state.entry.text.message, .text)
        .fireAndForget()
    }
  }
)

public struct EntryDetailView: View {
  public let store: Store<EntryDetailState, EntryDetailAction>
  
  public init(store: Store<EntryDetailState, EntryDetailAction>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store) { viewStore in
      ScrollView(showsIndicators: false) {
        VStack(spacing: 16) {
          
          if !viewStore.attachments.isEmpty {
            
            ScrollView(.horizontal, showsIndicators: false) {
              LazyHStack(spacing: 8) {
                ForEachStore(
                  store.scope(
                    state: \.attachments,
                    action: EntryDetailAction.attachments(id:action:)),
                  content: AttachmentRowView.init(store:)
                )
              }
            }
            .frame(height: 52)
            .padding(.horizontal, 16)
            
            Divider()
              .frame(height: 1)
              .background(Color.adaptiveGray)
          }
          
          HStack {
            Text(viewStore.message)
              .foregroundColor(.adaptiveBlack)
              .adaptiveFont(.latoRegular, size: 10)
            Spacer()
          }
          .padding(.horizontal, 16)
        }
        .padding(.vertical, 16)
      }
      .overlay(
        
        ZStack {
          if viewStore.showAttachmentOverlayed {
            Color.adaptiveWhite
              .edgesIgnoringSafeArea(.all)
            
            ZStack {
              ScrollView(.init()) {
                TabView(selection: viewStore.binding(get: \.seletedAttachmentRowState, send: EntryDetailAction.selectedAttachmentRowAction)) {
                  ForEach(viewStore.attachments) { attachment in
                    AttachmentDetailView(
                      store: store.scope(
                        state: \.selectedAttachmentDetailState,
                        action: EntryDetailAction.attachmentDetail))
                    .tag(attachment)
                  }
                }
              }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .overlay(
              HStack(spacing: 32) {
                Button(action: {
                  viewStore.send(.removeAttachment)
                }) {
                  Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.chambray)
                }
                
                Button(action: {
                  viewStore.send(.processShareAttachment)
                }) {
                  Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.chambray)
                }
                
                Button(action: {
                  viewStore.send(.dismissAttachmentOverlayed)
                }) {
                  Image(systemName: "xmark")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.chambray)
                }
              }
                .padding()
              , alignment: .topTrailing
            )
          }
        }
          .transition(.move(edge: .bottom))
      )
      .fullScreenCover(
        isPresented: viewStore.binding(
          get: { $0.presentAddEntry },
          send: EntryDetailAction.presentAddEntry
        )
      ) {
        IfLetStore(
          store.scope(
            state: { $0.addEntryState },
            action: EntryDetailAction.addEntryAction),
          then: AddEntryView.init(store:)
        )
      }
      .alert(
        store.scope(state: \.removeAlert),
        dismiss: .dismissRemoveAlert
      )
      .onAppear {
        viewStore.send(.onAppear)
      }
      .navigationBarTitle(viewStore.entry.stringLongDate, displayMode: .inline)
      .navigationBarItems(
        trailing: HStack(spacing: 16) {
          
          Button(
            action: {
              viewStore.send(.alertRemoveButtonTapped)
            }, label: {
              Image(systemName: "trash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundColor(.chambray)
            }
          )
          
          Button(
            action: {
              viewStore.send(.meatballActionSheetButtonTapped)
            }, label: {
              Image(systemName: "ellipsis")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundColor(.chambray)
            }
          )
          .confirmationDialog(
            store.scope(state: \.meatballActionSheet),
            dismiss: .dismissMeatballActionSheet
          )
        }
      )
      .navigationBarHidden(viewStore.showAttachmentOverlayed)
    }
  }
}
