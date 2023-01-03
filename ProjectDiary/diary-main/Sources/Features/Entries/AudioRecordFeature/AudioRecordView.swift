import ComposableArchitecture
import SwiftUI
import Views
import Styles
import Localizables
import SwiftHelper
import Models

public struct AudioRecordView: View {
  let store: StoreOf<AudioRecord>
  
  public init(
    store: StoreOf<AudioRecord>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(
      self.store,
      observe: { $0 }
    ) { viewStore in
      VStack(spacing: 16) {
        
        HStack(spacing: 24) {
          Spacer()
          
          Button(
            action: { viewStore.send(.dismiss) },
            label: {
              Image(systemName: "xmark")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 16, height: 16)
                .foregroundColor(.chambray)
            }
          )
        }
        
        Spacer()
        
        switch viewStore.audioRecordPermission {
        case .notDetermined, .denied:
          Text(viewStore.audioRecordPermission.description)
            .multilineTextAlignment(.center)
            .foregroundColor(.chambray)
            .adaptiveFont(.latoRegular, size: 14)
          Spacer()
          PrimaryButtonView(
            label: { Text(viewStore.audioRecordPermission.buttonTitle) },
            action: { viewStore.send(.permissionButtonTapped) }
          )
          
        case .authorized:
          Group {
            ZStack(alignment: .leading) {
              Capsule()
                .fill(Color.black.opacity(0.08))
                .frame(height: 8)
              Capsule()
                .fill(Color.red)
                .frame(width: viewStore.playerProgress, height: 8)
                .animation(nil, value: UUID())
                .gesture(
                  DragGesture()
                    .onChanged { viewStore.send(.dragOnChanged($0.location)) }
                    .onEnded { viewStore.send(.dragOnEnded($0.location)) }
                )
            }
            
            HStack {
              Text(viewStore.playerProgressTime.formatter)
                .adaptiveFont(.latoRegular, size: 10)
                .foregroundColor(.chambray)
              
              
              Spacer()
              
              Text(viewStore.playerDuration.formatter)
                .adaptiveFont(.latoRegular, size: 10)
                .foregroundColor(.chambray)
            }
            
            HStack {
              Rectangle()
                .frame(width: 24, height: 24)
                .opacity(0)
              
              Spacer()
              
              HStack(spacing: 42) {
                Button(
                  action: { viewStore.send(.playerGoBackward) },
                  label: {
                    Image(systemName: "gobackward.15")
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 24, height: 24)
                      .foregroundColor(.chambray)
                  }
                )
                
                Button(
                  action: { viewStore.send(.playButtonTapped) },
                  label: {
                    Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 32, height: 32)
                      .foregroundColor(.chambray)
                  }
                )
                
                Button(
                  action: { viewStore.send(.playerGoForward) },
                  label: {
                    Image(systemName: "goforward.15")
                      .resizable()
                      .aspectRatio(contentMode: .fill)
                      .frame(width: 24, height: 24)
                      .foregroundColor(.chambray)
                  }
                )
              }
              
              Spacer()
              
              Button(
                action: { viewStore.send(.removeAudioRecord) },
                label: {
                  Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.chambray)
                }
              )
            }
            
            Spacer()
          }
          .opacity(viewStore.hasAudioRecorded ? 1.0 : 0.0)
          .animation(.default, value: UUID())
          
          Text(viewStore.audioRecordDuration.formatter)
            .adaptiveFont(.latoBold, size: 20)
            .foregroundColor(.adaptiveBlack)
          
          RecordButtonView(
            isRecording: viewStore.isRecording,
            size: 100,
            action: { viewStore.send(.recordButtonTapped) }
          )
          
          Text("AudioRecord.StartRecording".localized)
            .multilineTextAlignment(.center)
            .adaptiveFont(.latoRegular, size: 10)
            .foregroundColor(.adaptiveGray)
          
          Spacer()
          
          PrimaryButtonView(
            label: { Text("AudioRecord.Add".localized) },
            disabled: !viewStore.hasAudioRecorded,
            action: { viewStore.send(.addAudio) }
          )
        }
      }
      .padding()
      .onAppear { viewStore.send(.onAppear) }
      .alert(
        store.scope(state: \.dismissAlert),
        dismiss: .dismissCancelAlert
      )
      .alert(
        store.scope(state: \.recordAlert),
        dismiss: .recordCancelAlert
      )
    }
  }
}

struct AudioRecordView_Preview: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AudioRecordView(
        store: .init(
          initialState: .init(audioRecordPermission: .denied),
          reducer: AudioRecord()
        )
      )
    }
  }
}
