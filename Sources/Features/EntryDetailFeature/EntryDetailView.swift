import ComposableArchitecture
import DesignSystem
import Localizables
import Models
import SwiftUI

public struct EntryDetailView: View {
	@Bindable var store: StoreOf<EntryDetailFeature>
	
	public init(
		store: StoreOf<EntryDetailFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		VStack(alignment: .leading, spacing: 24) {
			TextEditorView(
				placeholder: "AddEntry.WriteSomething".localized,
        text: $store.entry.message
			)
      DatePicker("", selection: self.$store.entry.updatedAt)
			
//			if self.store.attachments.count > 0 {
//				ScrollView(.horizontal, showsIndicators: false) {
//					LazyHStack(spacing: 8) {
//						ForEach(
//							self.store.scope(state: \.attachments, action: \.attachments),
//							id: \.id
//						) { store in
//							AttachmentAddRowView(store: store)
//						}
//					}
//				}
//				.frame(height: 52)
//			}
			
      HStack(spacing: 8) {
        SecondaryButtonView(
          label: {
            Text(
              store.entry.id != nil
              ? "Entries.Edit".localized
              : "AddEntry.Add".localized
            )
            .adaptiveFont(.latoRegular, size: 10)
            .foregroundColor(.chambray)
          },
          disabled: self.store.entry.message.isEmpty
        ) {
          self.store.send(.addEntryButtonTapped)
				}
				
				SecondaryButtonView(
					label: {
            Image(systemName: .plus)
							.resizable()
							.foregroundColor(.chambray)
							.frame(width: 16, height: 16)
					},
					inFlight: false
				) {
//					self.store.send(.confirmationDialogButtonTapped)
				}
				.frame(width: 56)
			}
			.frame(height: 56)
		}
		.padding(24)
//		.alert(
//			store: self.store.scope(state: \.$alert, action: \.alert)
//		)
//		.confirmationDialog(
//			store: self.store.scope(state: \.$dialog, action: \.dialog)
//		)
//		.fullScreenCover(
//			isPresented: self.$store.presentImagePicker.sending(\.presentImagePicker)
//		) {
//			ImagePicker(
//				type: self.store.presentImagePickerSource,
//				onImport: { response in
//					self.store.send(.loadAttachment(response))
//				}
//			)
//			.edgesIgnoringSafeArea(.all)
//		}
//		.fullScreenCover(
//			isPresented: self.$store.presentAudioPicker.sending(\.presentAudioPicker)
//		) {
//			AudioPicker { audio in
//				switch audio {
//					case let .audio(url):
//						self.store.send(.loadAudio(url))
//				}
//			}
//		}
//		.fullScreenCover(
//			store: self.store.scope(state: \.$audioRecord, action: \.audioRecord)
//		) { store in
//			AudioRecordView(store: store)
//		}
//		.onAppear {
//			self.store.send(.onAppear)
//		}
	}
}

#Preview {
  NavigationStack {
    EntryDetailView(
      store: Store(
        initialState: EntryDetailFeature.State(
          entry: Entry.Draft(
            id: UUID(1),
            createdAt: Date(),
            updatedAt: Date(),
            message: ""
          )
        ),
        reducer: { EntryDetailFeature() }
      )
    )
  }
}
