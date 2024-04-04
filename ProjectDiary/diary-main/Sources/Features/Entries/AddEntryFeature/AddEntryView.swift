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
  let store: StoreOf<AddEntryFeature>
  
  public init(
    store: StoreOf<AddEntryFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      
      VStack(alignment: .leading, spacing: 24) {
        HStack {
          Text(viewStore.type.title)
            .adaptiveFont(.latoBold, size: 16)
            .foregroundColor(.adaptiveBlack)
          Spacer()
          
          if viewStore.type == .add {
            Button(action: {
              viewStore.send(.dismissAlertButtonTapped)
            }, label: {
              Image(.xmark)
                .foregroundColor(.adaptiveBlack)
            })
          }
        }
        
        TextEditorView(
          placeholder: "AddEntry.WriteSomething".localized,
          text: viewStore.binding(
            get: \.text,
            send: AddEntryFeature.Action.textEditorChange)
        )
        
        if viewStore.attachments.count > 0 {
          ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
              ForEachStore(
                store.scope(
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
              Text(viewStore.type.finishTitle)
                .adaptiveFont(.latoRegular, size: 10)
                .foregroundColor(.chambray)
            },
            disabled: viewStore.text.isEmpty
          ) {
            viewStore.send(.addButtonTapped)
          }
          
          SecondaryButtonView(
            label: {
              Image(.plus)
                .resizable()
                .foregroundColor(.chambray)
                .frame(width: 16, height: 16)
            },
            inFlight: viewStore.addAttachmentInFlight
          ) {
            viewStore.send(.plusAttachamentActionSheetButtonTapped)
          }
          .frame(width: 56)
					.confirmationDialog(
						store: self.store.scope(state: \.$confirmationDialog, action: { .confirmationDialog($0) })
					)
        }
        .frame(height: 56)
      }
      .padding(24)
			.alert(
				store: self.store.scope(state: \.$alert, action: { .alert($0) })
			)
      .fullScreenCover(isPresented: viewStore.binding(
        get: \.presentImagePicker,
        send: AddEntryFeature.Action.presentImagePicker
      )) {
        ImagePicker(
          type: viewStore.presentImagePickerSource,
          onImport: { response in
            viewStore.send(.loadAttachment(response))
          }
        )
        .edgesIgnoringSafeArea(.all)
      }
      .fullScreenCover(isPresented: viewStore.binding(get: \.presentAudioPicker, send: AddEntryFeature.Action.presentAudioPicker)) {
        AudioPicker { audio in
          switch audio {
          case let .audio(url):
            viewStore.send(.loadAudio(url))
          }
        }
      }
      .fullScreenCover(isPresented: viewStore.binding(get: \.presentAudioRecord, send: AddEntryFeature.Action.presentAudioRecord)) {
        IfLetStore(
          store.scope(
            state: { $0.audioRecordState },
            action: AddEntryFeature.Action.audioRecordAction),
          then: AudioRecordView.init(store:)
        )
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

#Preview {
	NavigationStack {
		AddEntryView(
			store: Store(
				initialState: AddEntryFeature.State(
					entry: .mock,
					type: .add
				),
				reducer: { AddEntryFeature() }
			)
		)
	}
}
