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
	
	private struct ViewState: Equatable {
		let presentImagePicker: Bool
		let text: String
		let hasAttachments: Bool
		let presentAudioPicker: Bool
		let addAttachmentInFlight: Bool
		let presentImagePickerSource: PickerSourceType
		
		init(
			state: AddEntryFeature.State
		) {
			self.hasAttachments = state.attachments.count > 0
			self.presentImagePicker = state.presentImagePicker
			self.text = state.text
			self.presentAudioPicker = state.presentAudioPicker
			self.addAttachmentInFlight = state.addAttachmentInFlight
			self.presentImagePickerSource = state.presentImagePickerSource
		}
	}
	public init(
		store: StoreOf<AddEntryFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		WithViewStore(
			self.store,
			observe: ViewState.init
		) { viewStore in
			VStack(alignment: .leading, spacing: 24) {
				TextEditorView(
					placeholder: "AddEntry.WriteSomething".localized,
					text: viewStore.binding(
						get: \.text,
						send: AddEntryFeature.Action.textEditorChange)
				)
				
				if viewStore.hasAttachments {
					ScrollView(.horizontal, showsIndicators: false) {
						LazyHStack(spacing: 8) {
							ForEachStore(
								self.store.scope(
									state: \.attachments,
									action: AddEntryFeature.Action.attachments(id:action:)),
								content: AttachmentAddRowView.init(store:))
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
				isPresented: viewStore.binding(
					get: \.presentImagePicker,
					send: AddEntryFeature.Action.presentImagePicker
				)
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
				isPresented: viewStore.binding(
					get: \.presentAudioPicker,
					send: AddEntryFeature.Action.presentAudioPicker
				)
			) {
				AudioPicker { audio in
					switch audio {
						case let .audio(url):
							viewStore.send(.loadAudio(url))
					}
				}
			}
//			.fullScreenCover(isPresented: viewStore.binding(get: \.presentAudioRecord, send: AddEntryFeature.Action.presentAudioRecord)) {
//				IfLetStore(
//					store.scope(
//						state: { $0.audioRecordState },
//						action: AddEntryFeature.Action.audioRecordAction),
//					then: AudioRecordView.init(store:)
//				)
//			}
			.onAppear {
				viewStore.send(.onAppear)
			}
		}
	}
}

struct AddEntryView_Previews: PreviewProvider {
	static var previews: some View {
		AddEntryView(
			store: Store(
				initialState: AddEntryFeature.State(
					entry: .mock
				),
				reducer: AddEntryFeature()
			)
		)
	}
}
