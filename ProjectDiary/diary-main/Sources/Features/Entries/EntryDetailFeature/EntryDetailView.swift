import SwiftUI
import ComposableArchitecture
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
import BackgroundQueue

public struct EntryDetail: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var entry: Entry
    public var attachments: IdentifiedArrayOf<AttachmentRow.State> = []
    
    public var meatballActionSheet: ConfirmationDialogState<Action>?
    public var removeAlert: AlertState<Action>?
    
    public var addEntryState: AddEntry.State?
    public var presentAddEntry = false
    
    public var showAttachmentOverlayed = false
    public var seletedAttachmentRowState: AttachmentRow.State! = AttachmentRow.State(id: UUID(), attachment: .image(.init(entryImage: .init(id: UUID(), lastUpdated: .init(), thumbnail: URL(string: "www.google.es")!, url: URL(string: "www.google.es")!)))) {
      didSet {
        self.selectedAttachmentDetailState = AttachmentDetail.State(row: seletedAttachmentRowState)
      }
    }
    
    public var selectedAttachmentDetailState: AttachmentDetail.State! = AttachmentDetail.State(row: AttachmentRow.State(id: UUID(), attachment: .image(.init(entryImage: .init(id: UUID(), lastUpdated: .init(), thumbnail: URL(string: "www.google.es")!, url: URL(string: "www.google.es")!)))))
    
    public init(
      entry: Entry
    ) {
      self.entry = entry
    }
    
    var message: String {
      entry.text.message
    }
  }

  public enum Action: Equatable {
    case onAppear
    case entryResponse(Entry)
    
    case attachments(id: UUID, action: AttachmentRow.Action)
    case removeAttachmentResponse(UUID)
    
    case meatballActionSheetButtonTapped
    case dismissMeatballActionSheet
    
    case alertRemoveButtonTapped
    case dismissRemoveAlert
    case remove(Entry)
    
    case addEntryAction(AddEntry.Action)
    case presentAddEntry(Bool)
    case presentAddEntryCompleted
    
    case processShare
    
    case selectedAttachmentRowAction(AttachmentRow.State)
    case dismissAttachmentOverlayed
    case attachmentDetail(AttachmentDetail.Action)
    case removeAttachment
    case processShareAttachment
  }
  
  @Dependency(\.applicationClient) private var applicationClient
  @Dependency(\.fileClient) private var fileClient
  @Dependency(\.mainQueue) private var mainQueue
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
      .forEach(\.attachments, action: /Action.attachments) {
        AttachmentRow()
      }
      .ifLet(\.addEntryState, action: /EntryDetail.Action.addEntryAction) {
        AddEntry()
      }
    Scope(state: \.selectedAttachmentDetailState, action: /Action.attachmentDetail) {
      AttachmentDetail()
    }
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action, Never> {
    switch action {
    case let .attachments(id: id, action: .attachment(.image(.presentImageFullScreen(true)))),
      let .attachments(id: id, action: .attachment(.video(.presentVideoPlayer(true)))),
      let .attachments(id: id, action: .attachment(.audio(.presentAudioFullScreen(true)))):
      state.seletedAttachmentRowState = state.attachments[id: id]
      state.showAttachmentOverlayed = true
      self.applicationClient.showTabView(true)
      return .none
      
    case let .selectedAttachmentRowAction(selected):
      state.seletedAttachmentRowState = selected
      return .none
      
    case .dismissAttachmentOverlayed:
      state.showAttachmentOverlayed = false
      self.applicationClient.showTabView(false)
      return .none
      
    case .attachmentDetail:
      return .none
      
    case .processShareAttachment:
      let attachmentState = state.seletedAttachmentRowState.attachment
      
      self.applicationClient.share(attachmentState.url, .attachment)
      return .none
      
    case .onAppear:
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
      
    case .removeAttachment:
      let attachmentState = state.seletedAttachmentRowState.attachment
      
      return .run { send in
        _ = await self.fileClient.removeAttachments([attachmentState.thumbnail, attachmentState.url].compactMap { $0 })
        await send(.removeAttachmentResponse(attachmentState.attachment.id))
      }
      
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
        .delay(for: 0.3, scheduler: self.mainQueue)
        .eraseToEffect()
      
    case .presentAddEntryCompleted:
      state.addEntryState = nil
      return Effect(value: .onAppear)
      
    case .processShare:
      self.applicationClient.share(state.entry.text.message, .text)
      return .none
    }
  }
}

public struct EntryDetailView: View {
  public let store: StoreOf<EntryDetail>
  
  public init(
    store: StoreOf<EntryDetail>
  ) {
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
                    action: EntryDetail.Action.attachments(id:action:)),
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
            Color.customBlack
              .edgesIgnoringSafeArea(.all)
            
            ZStack {
              ScrollView(.init()) {
                TabView(selection: viewStore.binding(get: \.seletedAttachmentRowState, send: EntryDetail.Action.selectedAttachmentRowAction)) {
                  ForEach(viewStore.attachments) { attachment in
                    AttachmentDetailView(
                      store: store.scope(
                        state: \.selectedAttachmentDetailState,
                        action: EntryDetail.Action.attachmentDetail))
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
                  Image(.trash)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.chambray)
                }
                
                Button(action: {
                  viewStore.send(.processShareAttachment)
                }) {
                  Image(.squareAndArrowUp)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.chambray)
                }
                
                Button(action: {
                  viewStore.send(.dismissAttachmentOverlayed)
                }) {
                  Image(.xmark)
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
          send: EntryDetail.Action.presentAddEntry
        )
      ) {
        IfLetStore(
          store.scope(
            state: { $0.addEntryState },
            action: EntryDetail.Action.addEntryAction),
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
              Image(.trash)
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
              Image(.ellipsis)
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
