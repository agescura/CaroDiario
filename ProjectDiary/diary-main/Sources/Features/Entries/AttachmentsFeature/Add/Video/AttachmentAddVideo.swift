import SwiftUI
import ComposableArchitecture
import FileClient
import Views
import Models
import Localizables
import UIApplicationClient
import AVKit

public struct AttachmentAddVideo: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    public var entryVideo: EntryVideo
    public var presentVideoPlayer: Bool = false
    
    public var videoAlert: AlertState<Action>?
    
    public init(
      entryVideo: EntryVideo
    ) {
      self.entryVideo = entryVideo
    }
  }
  
  public enum Action: Equatable {
    case presentVideoPlayer(Bool)
    case videoAlertButtonTapped
    case dismissRemoveFullScreen
    case remove
    case cancelRemoveFullScreenAlert
  }
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action> {
    switch action {
    case let .presentVideoPlayer(value):
      state.presentVideoPlayer = value
      return .none
      
    case .videoAlertButtonTapped:
      state.videoAlert = .init(
        title: .init("Video.Remove.Description".localized),
        primaryButton: .cancel(.init("Cancel".localized)),
        secondaryButton: .destructive(.init("Video.Remove.Title".localized), action: .send(.remove))
      )
      return .none
      
    case .dismissRemoveFullScreen:
      state.videoAlert = nil
      state.presentVideoPlayer = false
      return .none
      
    case .remove:
      state.presentVideoPlayer = false
      state.videoAlert = nil
      return .none
      
    case .cancelRemoveFullScreenAlert:
      state.videoAlert = nil
      return .none
    }
  }
}

struct AttachmentAddVideoView: View {
  let store: StoreOf<AttachmentAddVideo>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ZStack {
        ImageView(url: viewStore.entryVideo.thumbnail)
          .frame(width: 52, height: 52)
        Image(.playFill)
          .foregroundColor(.adaptiveWhite)
          .frame(width: 8, height: 8)
      }
      .onTapGesture {
        viewStore.send(.presentVideoPlayer(true))
      }
      .fullScreenCover(
        isPresented: viewStore.binding(
          get: \.presentVideoPlayer,
          send: AttachmentAddVideo.Action.presentVideoPlayer
        )
      ) {
        ZStack {
          Color.black
            .edgesIgnoringSafeArea(.all)
          
          VStack {
            HStack(spacing: 8) {
              Spacer()
              Button(action: {
                viewStore.send(.videoAlertButtonTapped)
              }) {
                Image(.trash)
                  .frame(width: 48, height: 48)
                  .foregroundColor(.chambray)
              }
              
              Button(action: {
                viewStore.send(.presentVideoPlayer(false))
              }) {
                Image(.xmark)
                  .frame(width: 48, height: 48)
                  .foregroundColor(.chambray)
              }
            }
            
            VideoPlayer(player: AVPlayer(url: viewStore.entryVideo.url))
              .edgesIgnoringSafeArea([.bottom, .horizontal])
          }
          .alert(
            store.scope(state: \.videoAlert),
            dismiss: .cancelRemoveFullScreenAlert
          )
        }
      }
    }
  }
}

