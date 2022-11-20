import ComposableArchitecture
import SwiftUI
import AVKit
import Models

public struct AttachmentVideoDetail: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
      public var entryVideo: EntryVideo
      
      public init(
          attachment: AttachmentVideoState
      ) {
          self.entryVideo = attachment.entryVideo
      }
  }

  public enum Action: Equatable {}
  
  public var body: some ReducerProtocolOf<Self> {
    EmptyReducer()
  }
}

public struct AttachmentVideoDetailView: View {
    let store: StoreOf<AttachmentVideoDetail>
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VideoPlayer(player: AVPlayer(url: viewStore.entryVideo.url))
                .padding(.bottom, 32)
        }
    }
}
