import SwiftUI
import ComposableArchitecture
import Models
import Views
import AttachmentsFeature
import AddEntryFeature

public struct EntryDetailView: View {
  let store: StoreOf<EntryDetailFeature>
  
  public init(
    store: StoreOf<EntryDetailFeature>
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
                    action: EntryDetailFeature.Action.attachments(id:action:)),
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
                TabView(selection: viewStore.binding(get: \.seletedAttachmentRowState, send: EntryDetailFeature.Action.selectedAttachmentRowAction)) {
                  ForEach(viewStore.attachments) { attachment in
                    AttachmentDetailView(
                      store: store.scope(
                        state: \.selectedAttachmentDetailState,
                        action: EntryDetailFeature.Action.attachmentDetail))
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
          send: EntryDetailFeature.Action.presentAddEntry
        )
      ) {
				NavigationStack {
					IfLetStore(
						store.scope(
							state: { $0.addEntryState },
							action: EntryDetailFeature.Action.addEntryAction),
						then: AddEntryView.init(store:)
					)
					.toolbar {
						ToolbarItem(placement: .cancellationAction) {
							Text("AddEntry.Edit".localized)
								.adaptiveFont(.latoBold, size: 16)
								.foregroundColor(.adaptiveBlack)
						}
						ToolbarItem(placement: .confirmationAction) {
							Button {
//								self.store.send(.add(.dismiss))
							} label: {
								Image(.xmark)
									.foregroundColor(.adaptiveBlack)
							}
						}
					}
				}
      }
			.alert(
				store: self.store.scope(
					state: \.$alert,
					action: { .alert($0) }
				)
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
						store: self.store.scope(
							state: \.$confirmationDialog,
							action: { .confirmationDialog($0) }
						)
					)
        }
      )
      .navigationBarHidden(viewStore.showAttachmentOverlayed)
    }
  }
}

#Preview {
	NavigationStack {
		EntryDetailView(
			store: Store(
				initialState: EntryDetailFeature.State(entry: .mock),
				reducer: { EntryDetailFeature() }
			)
		)
	}
}
