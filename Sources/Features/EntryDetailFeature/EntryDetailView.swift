import ComposableArchitecture
import DesignSystem
import Localizables
import Models
import Photos
import PhotosUI
import SQLiteData
import SQLiteDataClient
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
			
			if self.store.attachmentsRows.count > 0 {
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(spacing: 8) {
            ForEach(self.store.attachmentsRows, id: \.self) { attachment in
              if attachment.format == "image", let image = UIImage(data: attachment.data) {
                Button {
                  store.send(.attachmentButtonTapped(attachment))
                } label: {
                  Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .foregroundStyle(Color.gray)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
              }
              if attachment.format == "video" {
                Button {
                  store.send(.attachmentButtonTapped(attachment))
                } label: {
                  Rectangle()
                    .foregroundStyle(Color.gray)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
              }
						}
					}
				}
				.frame(height: 52)
			}
      
      DatePicker("", selection: self.$store.entry.updatedAt)
			
      HStack(spacing: 8) {
        SecondaryButtonView(
          label: {
            Text("Save".localized)
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
					self.store.send(.dialogButtonTapped)
				}
				.frame(width: 56)
        .confirmationDialog(
          store: self.store.scope(state: \.$dialog, action: \.dialog)
        )
			}
			.frame(height: 56)
		}
		.padding(24)
    .fullScreenCover(
      item: $store.scope(
        state: \.attachment,
        action: \.attachment
      )
    ) { store in
      NavigationStack {
        AttachmentView(store: store)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button {
                self.store.send(.dismissButtonTapped)
              } label: {
                Image(systemName: .xmark)
              }
            }
            ToolbarItem {
              Button {
                self.store.send(.removeAttachmentButtonTapped)
              } label: {
                Image(systemName: .trash)
              }
            }
          }
      }
    }
    .photosPicker(
      isPresented: $store.isPhotoPickerPresented,
      selection: $store.photosPickerItem
    )
    .task { await store.send(.task).finish() }
	}
}

#Preview {
  let _ = prepareDependencies {
    try! $0.bootstrapDatabase()
    try! $0.defaultDatabase.seed()
  }
  return NavigationStack {
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
        reducer: { EntryDetailFeature()._printChanges() }
      )
    )
  }
}
