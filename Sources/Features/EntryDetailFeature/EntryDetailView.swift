import ComposableArchitecture
import DesignSystem
import Localizables
import Models
import Photos
import PhotosUI
import SQLiteData
import SQLiteDataClient
import SwiftUI

@ViewAction(for: EntryDetailFeature.self)
public struct EntryDetailView: View {
	@Bindable public var store: StoreOf<EntryDetailFeature>
	
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
			
			if store.attachmentsRows.count > 0 {
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(spacing: 8) {
            ForEach(store.attachmentsRows, id: \.self) { attachment in
              switch attachment.format {
              case .image:
                Button {
                  send(.attachmentButtonTapped(attachment))
                } label: {
                  AsyncImage(url: attachment.fileUrl) { image in
                    image
                      .resizable()
                      .scaledToFill()
                      .foregroundStyle(Color.gray)
                      .frame(width: 44, height: 44)
                      .clipShape(RoundedRectangle(cornerRadius: 8))
                  } placeholder: {
                    ProgressView()
                  }
                }
              case .video:
                Button {
                  send(.attachmentButtonTapped(attachment))
                } label: {
                  if let image = attachment.imagePreview {
                    Image(uiImage: image)
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 44, height: 44)
                      .clipShape(RoundedRectangle(cornerRadius: 8))
                  } else {
                    Rectangle()
                      .foregroundStyle(Color.gray)
                      .frame(width: 44, height: 44)
                      .clipShape(RoundedRectangle(cornerRadius: 8))
                  }
                }
              case .audio:
                Text("AUDIO")
              }
						}
					}
				}
				.frame(height: 52)
			}
      
      DatePicker("", selection: self.$store.entry.updatedAt)
			
      HStack(spacing: .s16) {
        Button("Save".localized) {
          send(.addEntryButtonTapped)
        }
        .buttonStyle(.secondary)
        .disabled(store.entry.message.isEmpty)
        
        Button(systemName: .plus) {
          send(.dialogButtonTapped)
        }
        .buttonStyle(.secondary)
				.frame(width: 56)
        .confirmationDialog(
          store: store.scope(state: \.$dialog, action: \.dialog)
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
                send(.dismissButtonTapped)
              } label: {
                Image(systemName: .xmark)
              }
            }
            ToolbarItem {
              Button {
                send(.removeAttachmentButtonTapped)
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
    .task { await send(.task).finish() }
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
            isDraft: false,
            updatedAt: Date(),
            message: ""
          )
        ),
        reducer: { EntryDetailFeature() }
      )
    )
  }
}
