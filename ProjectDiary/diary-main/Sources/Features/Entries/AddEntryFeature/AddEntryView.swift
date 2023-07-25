import SwiftUI
import ComposableArchitecture
import Models
import Views
import ImagePickerFeature
import Localizables
import AttachmentsFeature
import AudioPickerFeature
import AudioRecordFeature

public struct AddEntryView: View {
	private let store: StoreOf<AddEntryFeature>
	
	struct ViewState: Equatable {
		@BindingViewState var entry: Entry
		@BindingViewState var presentImagePicker: Bool
		let hasAttachments: Bool
		@BindingViewState var presentAudioPicker: Bool
		let addAttachmentInFlight: Bool
		let presentImagePickerSource: PickerSourceType
	}
	
	public init(
		store: StoreOf<AddEntryFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: \.view,
			send: { .view($0) }
		) { viewStore in
			VStack(alignment: .leading, spacing: 24) {
				TextEditorView(
					placeholder: "AddEntry.WriteSomething".localized,
					text: viewStore.$entry.text.message
				)
				if viewStore.hasAttachments {
					ScrollView(.horizontal, showsIndicators: false) {
						LazyHStack(spacing: 8) {
							ForEachStore(
								self.store.scope(
									state: \.attachments,
									action: AddEntryFeature.Action.attachments
								),
								content: AttachmentAddRowView.init
							)
						}
					}
					.frame(height: 52)
				}

				HStack(spacing: 8) {
					SecondaryButtonView(
						label: {
							Text("AddEntry.Finish".localized)
								.adaptiveFont(.latoRegular, size: 10)
								.foregroundColor(.chambray)
						},
						disabled: viewStore.entry.text.message.isEmpty
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
						viewStore.send(.confirmationDialogButtonTapped)
					}
					.frame(width: 56)
				}
				.frame(height: 56)
			}
			.padding(24)
			.alert(
				store: self.store.scope(
					state: \.$destination,
					action: AddEntryFeature.Action.destination
				),
				state: /AddEntryFeature.Destination.State.alert,
				action: AddEntryFeature.Destination.Action.alert
			)
			.confirmationDialog(
				store: self.store.scope(
					state: \.$destination,
					action: AddEntryFeature.Action.destination
				),
				state: /AddEntryFeature.Destination.State.confirmationDialog,
				action: AddEntryFeature.Destination.Action.confirmationDialog
			)
			.fullScreenCover(
				isPresented: viewStore.$presentImagePicker
			) {
				ImagePicker(
					type: viewStore.presentImagePickerSource,
					onImport: { response in
						viewStore.send(.loadAttachment(response))
					}
				)
				.edgesIgnoringSafeArea(.all)
			}
			.fullScreenCover(
				isPresented: viewStore.$presentAudioPicker
			) {
				AudioPicker { audio in
					switch audio {
						case let .audio(url):
							viewStore.send(.loadAudio(url))
					}
				}
			}
			.fullScreenCover(
				store: self.store.scope(
					state: \.$destination,
					action: AddEntryFeature.Action.destination
				),
				state: /AddEntryFeature.Destination.State.audioRecord,
				action: AddEntryFeature.Destination.Action.audioRecord
			) { store in
				NavigationView {
					AudioRecordView(store: store)
						.toolbar {
							ToolbarItem(placement: .primaryAction) {
								Button {
									viewStore.send(.dismiss)
								} label: {
									Image(systemName: "xmark")
										.resizable()
										.aspectRatio(contentMode: .fill)
										.frame(width: 16, height: 16)
										.foregroundColor(.chambray)
								}
							}
						}
				}
			}
			.onAppear {
				viewStore.send(.onAppear)
			}
		}
	}
}

extension BindingViewStore<AddEntryFeature.State> {
  var view: AddEntryView.ViewState {
	  AddEntryView.ViewState(
		entry: self.$entry,
		presentImagePicker: self.$presentImagePicker,
		hasAttachments: self.attachments.count > 0,
		presentAudioPicker: self.$presentAudioPicker,
		addAttachmentInFlight: self.addAttachmentInFlight,
		presentImagePickerSource: self.presentImagePickerSource
	  )
  }
}

struct AddEntryView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			AddEntryView(
				store: Store(
					initialState: AddEntryFeature.State(
						entry: .mock
					),
					reducer: AddEntryFeature()
				)
			)
			.navigationTitle("Add Entry")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}
