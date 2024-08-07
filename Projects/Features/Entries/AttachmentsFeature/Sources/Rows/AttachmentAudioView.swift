import SwiftUI
import ComposableArchitecture
import Views
import Models

public struct AttachmentAudio: Reducer {
  public init() {}
  
  public struct State: Equatable {
    public var entryAudio: EntryAudio
    
    public init(
      entryAudio: EntryAudio
    ) {
      self.entryAudio = entryAudio
    }
  }
  
  public enum Action: Equatable {
    case presentAudioFullScreen(Bool)
  }
  
  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}

struct AttachmentAudioView: View {
  let store: StoreOf<AttachmentAudio>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Rectangle()
        .fill(Color.adaptiveGray)
        .frame(width: 52, height: 52)
        .overlay(
          Image(.waveform)
            .foregroundColor(.adaptiveWhite)
            .frame(width: 8, height: 8)
        )
        .onTapGesture {
          viewStore.send(.presentAudioFullScreen(true))
        }
    }
  }
}
