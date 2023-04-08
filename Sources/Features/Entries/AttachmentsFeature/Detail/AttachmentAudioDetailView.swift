import ComposableArchitecture
import SwiftUI
import Models
import FileClient
import UIApplicationClient
import AVAudioPlayerClient
import SwiftHelper
import SwiftUIHelper

public struct AttachmentAudioDetail: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    let entryAudio: EntryAudio
    
    var isPlaying: Bool = false
    var playerDuration: Double = 0
    var isPlayerDragging: Bool = false
    var isDragging = false
    var playerProgress: CGFloat = 0
    var playerProgressTime: Double = 0
    
    public init(
      attachment: AttachmentAudio.State
    ) {
      self.entryAudio = attachment.entryAudio
    }
  }
  
  public enum Action: Equatable {
    case onAppear
    case audioPlayer(AVAudioPlayerClient.Action)
    
    case playButtonTapped
    case isPlayingResponse(Bool)
    case playerProgressAddTimer
    case playerProgressResponse(Double)
    case dragOnChanged(CGPoint)
    case dragOnEnded(CGPoint)
    case playerGoBackward
    case playerGoForward
  }
  
  @Dependency(\.avAudioPlayerClient) private var avAudioPlayerClient
  
  private struct PlayerManagerId: Hashable {}
  private struct PlayerTimerId: Hashable {}
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> EffectTask<Action> {
    switch action {
    case .onAppear:
      return self.avAudioPlayerClient.create(id: PlayerManagerId(), url: state.entryAudio.url)
        .map(Action.audioPlayer)
      
    case .audioPlayer(.didFinishPlaying):
      state.playerProgress = 0
      state.isPlaying = false
      state.playerProgressTime = 0
      return .cancel(id: PlayerTimerId())
      
    case let .audioPlayer(.duration(duration)):
      state.playerDuration = duration
      return .none
      
    case .audioPlayer:
      return .none
      
    case .playButtonTapped:
      return self.avAudioPlayerClient.isPlaying(id: PlayerManagerId())
        .map(Action.isPlayingResponse)
      
    case let .isPlayingResponse(isPlaying):
      if isPlaying {
        state.isPlaying = false
        return .merge(
          self.avAudioPlayerClient.pause(id: PlayerManagerId())
            .fireAndForget(),
          .cancel(id: PlayerTimerId())
        )
      } else {
        state.isPlaying = true
        return .merge(
          self.avAudioPlayerClient.play(id: PlayerManagerId())
            .fireAndForget(),
          EffectTask.timer(id: PlayerTimerId(), every: 0.1, on: DispatchQueue.main)
            .map { _ in .playerProgressAddTimer }
        )
      }
      
    case .playerProgressAddTimer:
      if state.isDragging { return .none }
      
      return self.avAudioPlayerClient.currentTime(id: PlayerManagerId())
        .map(Action.playerProgressResponse)
      
    case let .playerProgressResponse(progress):
      state.playerProgressTime = progress
      
      let screen = UIScreen.main.bounds.width - 30
      let value = progress / state.playerDuration
      state.playerProgress = screen * CGFloat(value)
      return .none
      
    case let .dragOnChanged(position):
      state.isDragging = true
      state.playerProgress = position.x
      return .none
      
    case let .dragOnEnded(position):
      state.isDragging = false
      let screen = UIScreen.main.bounds.width - 30
      let percentage = position.x / screen
      state.playerProgressTime = Double(percentage) * state.playerDuration
      return self.avAudioPlayerClient.setCurrentTime(id: PlayerManagerId(), currentTime: state.playerProgressTime)
        .fireAndForget()
      
    case .playerGoBackward:
      var decrease = state.playerProgressTime - 15
      if decrease < 0 { decrease = 0 }
      return self.avAudioPlayerClient.setCurrentTime(id: PlayerManagerId(), currentTime: decrease)
        .fireAndForget()
      
    case .playerGoForward:
      let increase = state.playerProgressTime + 15
      if increase < state.playerDuration {
        state.playerProgressTime = increase
        return self.avAudioPlayerClient.setCurrentTime(id: PlayerManagerId(), currentTime: state.playerProgressTime)
          .fireAndForget()
      }
      return .none
    }
  }
}

public struct AttachmentAudioDetailView: View {
  let store: StoreOf<AttachmentAudioDetail>
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        
        Spacer()
        
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
                  .onChanged { value in
                    viewStore.send(.dragOnChanged(value.location))
                  }
                  .onEnded { value in
                    viewStore.send(.dragOnEnded(value.location))
                  }
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
            
            Button(action: {}, label: {})
              .frame(width: 24, height: 24)
              .opacity(0)
            
            Spacer()
            
            HStack(spacing: 42) {
              Button(action: {
                viewStore.send(.playerGoBackward)
              }, label: {
                Image(.gobackward15)
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 24, height: 24)
                  .foregroundColor(.chambray)
              })
              
              
              Button(action: {
                viewStore.send(.playButtonTapped)
              }, label: {
                Image(viewStore.isPlaying ? .pauseFill : .playFill)
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 32, height: 32)
                  .foregroundColor(.chambray)
              })
              
              Button(action: {
                viewStore.send(.playerGoForward)
              }, label: {
                Image(.goforward15)
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 24, height: 24)
                  .foregroundColor(.chambray)
              })
            }
            Spacer()
          }
        }
        .padding()
        .animation(.default, value: UUID())
        .onAppear {
          viewStore.send(.onAppear)
        }
        
        Spacer()
      }
    }
  }
}
