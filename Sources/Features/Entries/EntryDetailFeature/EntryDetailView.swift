import SwiftUI
import ComposableArchitecture
import Models
import Views
import AttachmentsFeature
import AddEntryFeature

public struct EntryDetailView: View {
  public let store: StoreOf<EntryDetail>
  
  public init(
    store: StoreOf<EntryDetail>
  ) {
    self.store = store
  }
  
  public var body: some View {
      WithViewStore(self.store, observe: { $0 }) { viewStore in
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
