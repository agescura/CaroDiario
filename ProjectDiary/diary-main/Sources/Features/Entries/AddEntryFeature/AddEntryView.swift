import SwiftUI
import ComposableArchitecture
import Models
import Views
import ImagePickerFeature
import Localizables
import AttachmentsFeature
import AudioPickerFeature
import AudioRecordFeature
import SwiftUIHelper

public struct AddEntryView: View {
	@Perception.Bindable var store: StoreOf<AddEntryFeature>
  
  public init(
    store: StoreOf<AddEntryFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
		WithPerceptionTracking {
      VStack(alignment: .leading, spacing: 24) {
        TextEditorView(
          placeholder: "AddEntry.WriteSomething".localized,
					text: self.$store.text.sending(\.textEditorChange)
        )
        
				if self.store.attachments.count > 0 {
					ScrollView(.horizontal, showsIndicators: false) {
						LazyHStack(spacing: 8) {
							ForEach(
								self.store.scope(state: \.attachments, action: \.attachments),
								id: \.id
							) { store in
								WithPerceptionTracking {
									AttachmentAddRowView(store: store)
								}
							}
						}
					}
          .frame(height: 52)
        }
        
        HStack(spacing: 8) {
          SecondaryButtonView(
            label: {
              Text("AddEntry.Add".localized)
                .adaptiveFont(.latoRegular, size: 10)
                .foregroundColor(.chambray)
            },
            disabled: self.store.text.isEmpty
          ) {
						self.store.send(.addButtonTapped)
          }
          
          SecondaryButtonView(
            label: {
              Image(.plus)
                .resizable()
                .foregroundColor(.chambray)
                .frame(width: 16, height: 16)
            },
            inFlight: self.store.addAttachmentInFlight
          ) {
						self.store.send(.confirmationDialogButtonTapped)
          }
          .frame(width: 56)
        }
        .frame(height: 56)
      }
      .padding(24)
			.alert(
				store: self.store.scope(state: \.$alert, action: \.alert)
			)
			.confirmationDialog(
				store: self.store.scope(state: \.$dialog, action: \.dialog)
			)
			.fullScreenCover(
				isPresented: self.$store.presentImagePicker.sending(\.presentImagePicker)
			) {
				ImagePicker(
					type: self.store.presentImagePickerSource,
					onImport: { response in
						self.store.send(.loadAttachment(response))
					}
				)
				.edgesIgnoringSafeArea(.all)
			}
      .fullScreenCover(
				isPresented: self.$store.presentAudioPicker.sending(\.presentAudioPicker)
			) {
        AudioPicker { audio in
          switch audio {
          case let .audio(url):
							self.store.send(.loadAudio(url))
          }
        }
      }
			.fullScreenCover(
				store: self.store.scope(state: \.$audioRecord, action: \.audioRecord)
			) { store in
				AudioRecordView(store: store)
			}
			.onAppear {
				self.store.send(.onAppear)
			}
		}
	}
}

#Preview {
	NavigationStack {
		AddEntryView(
			store: Store(
				initialState: AddEntryFeature.State(
					entry: .mock
				),
				reducer: { AddEntryFeature() }
			)
		)
	}
}
