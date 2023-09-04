import AttachmentsFeature
import AddEntryFeature
import ComposableArchitecture
import Models
import SwiftUI
import Views

public struct EntryDetailView: View {
	private let store: StoreOf<EntryDetailFeature>
	
	public init(
		store: StoreOf<EntryDetailFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: { $0 }
		) { viewStore in
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
						Color.adaptiveWhite
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
			.onAppear {
				viewStore.send(.onAppear)
			}
			.navigationBarTitle(viewStore.entry.stringLongDate, displayMode: .inline)
			.navigationBarItems(
				trailing: HStack(spacing: 16) {
					
					Button(
						action: {
							viewStore.send(.alertButtonTapped)
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
							viewStore.send(.confirmationDialogButtonTapped)
						}, label: {
							Image(systemName: "ellipsis")
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(width: 16, height: 16)
								.foregroundColor(.chambray)
						}
					)
				}
			)
			.navigationBarHidden(viewStore.showAttachmentOverlayed)
			.fullScreenCover(
				store: self.store.scope(
					state: \.$destination,
					action: EntryDetailFeature.Action.destination
				),
				state: /EntryDetailFeature.Destination.State.edit,
				action: EntryDetailFeature.Destination.Action.edit
			) { store in
				AddEntryView(store: store)
					.navigationTitle("AddEntry.Edit".localized)
			}
			.alert(
				store: self.store.scope(
					state: \.$destination,
					action: EntryDetailFeature.Action.destination
				),
				state: /EntryDetailFeature.Destination.State.alert,
				action: EntryDetailFeature.Destination.Action.alert
			)
			.confirmationDialog(
				store: self.store.scope(
					state: \.$destination,
					action: EntryDetailFeature.Action.destination
				),
				state: /EntryDetailFeature.Destination.State.dialog,
				action: EntryDetailFeature.Destination.Action.dialog
			)
		}
	}
}
