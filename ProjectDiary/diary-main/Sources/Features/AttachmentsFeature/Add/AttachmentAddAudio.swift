//
//  AttachmentAddAudio.swift
//
//  Created by Albert Gil Escura on 6/10/21.
//

import SwiftUI
import ComposableArchitecture
import CoreDataClient
import FileClient
import SharedViews
import SharedModels
import UIApplicationClient
import AVAudioPlayerClient

public struct AttachmentAddAudioState: Equatable {
    public var entryAudio: SharedModels.EntryAudio
    public var presentAudioFullScreen: Bool = false
    
    public var removeFullScreenAlert: AlertState<AttachmentAddAudioAction>?
    public var removeAlert: AlertState<AttachmentAddAudioAction>?
    
    var isPlaying: Bool = false
    var playerDuration: Double = 0
    var isPlayerDragging: Bool = false
    var isDragging = false
    var playerProgress: CGFloat = 0
    var playerProgressTime: Double = 0

    public init(
        entryAudio: SharedModels.EntryAudio
    ) {
        self.entryAudio = entryAudio
    }
}

public enum AttachmentAddAudioAction: Equatable {
    case onAppear
        case presentAudioFullScreen(Bool)
        
        case remove
        case removeFullScreenAlertButtonTapped
        case dismissRemoveFullScreen
        case cancelRemoveFullScreenAlert
        
        case audioPlayer(AVAudioPlayerClient.Action)
        
        case playButtonTapped
        case isPlayingResponse(Bool)
        case playerProgressAddTimer
        case playerProgressResponse(Double)
        case dragOnChanged(CGPoint)
        case dragOnEnded(CGPoint)
        case playerGoBackward
        case playerGoForward
        
        case processShare
}

public struct AttachmentAddAudioEnvironment {
    public let fileClient: FileClient
    public let applicationClient: UIApplicationClient
    public var avAudioPlayerClient: AVAudioPlayerClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let backgroundQueue: AnySchedulerOf<DispatchQueue>
    
    public init(
        fileClient: FileClient,
        applicationClient: UIApplicationClient,
        avAudioPlayerClient: AVAudioPlayerClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        backgroundQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.fileClient = fileClient
        self.applicationClient = applicationClient
        self.avAudioPlayerClient = avAudioPlayerClient
        self.mainQueue = mainQueue
        self.backgroundQueue = backgroundQueue
    }
}

public let attachmentAddAudioReducer = Reducer<AttachmentAddAudioState, AttachmentAddAudioAction, AttachmentAddAudioEnvironment> { state, action, environment in
    struct PlayerManagerId: Hashable {}
        struct PlayerTimerId: Hashable {}
        
        switch action {
            
        case .onAppear:
            return environment.avAudioPlayerClient.create(id: PlayerManagerId(), url: state.entryAudio.url)
                .map(AttachmentAddAudioAction.audioPlayer)
        
        case let .presentAudioFullScreen(value):
            state.presentAudioFullScreen = value
            return .none
            
        case .removeFullScreenAlertButtonTapped:
            state.removeFullScreenAlert = .init(
                title: .init("Image.Remove.Description".localized),
                primaryButton: .cancel(.init("Cancel".localized)),
                secondaryButton: .destructive(.init("Image.Remove.Title".localized), action: .send(.remove))
            )
            return .none
            
        case .dismissRemoveFullScreen:
            state.removeFullScreenAlert = nil
            state.presentAudioFullScreen = false
            return .none
            
        case .remove:
            state.presentAudioFullScreen = false
            state.removeFullScreenAlert = nil
            return .none
            
        case .cancelRemoveFullScreenAlert:
            state.removeFullScreenAlert = nil
            return .none
            
        case let .audioPlayer(.didFinishPlaying(successfully: value)):
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
            return environment.avAudioPlayerClient.isPlaying(id: PlayerManagerId())
                .map(AttachmentAddAudioAction.isPlayingResponse)
            
        case let .isPlayingResponse(isPlaying):
            if isPlaying {
                state.isPlaying = false
                return .merge(
                    environment.avAudioPlayerClient.pause(id: PlayerManagerId())
                    .fireAndForget(),
                    .cancel(id: PlayerTimerId())
                )
            } else {
                state.isPlaying = true
                return .merge(
                    environment.avAudioPlayerClient.play(id: PlayerManagerId())
                    .fireAndForget(),
                    Effect.timer(id: PlayerTimerId(), every: 0.1, on: DispatchQueue.main)
                        .map { _ in .playerProgressAddTimer }
                )
            }
            
        case .playerProgressAddTimer:
            if state.isDragging { return .none }
            
            return environment.avAudioPlayerClient.currentTime(id: PlayerManagerId())
                .map(AttachmentAddAudioAction.playerProgressResponse)
            
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
            return environment.avAudioPlayerClient.setCurrentTime(id: PlayerManagerId(), currentTime: state.playerProgressTime)
                .fireAndForget()
            
        case .playerGoBackward:
            var decrease = state.playerProgressTime - 15
            if decrease < 0 { decrease = 0 }
            return environment.avAudioPlayerClient.setCurrentTime(id: PlayerManagerId(), currentTime: decrease)
                .fireAndForget()
            
        case .playerGoForward:
            let increase = state.playerProgressTime + 15
            if increase < state.playerDuration {
                state.playerProgressTime = increase
                return environment.avAudioPlayerClient.setCurrentTime(id: PlayerManagerId(), currentTime: state.playerProgressTime)
                    .fireAndForget()
            }
            return .none
            
        case .processShare:
            return environment.applicationClient.share(state.entryAudio.url)
                .fireAndForget()
        }
}

struct AttachmentAddAudioView: View {
    let store: Store<AttachmentAddAudioState, AttachmentAddAudioAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
                    Rectangle()
                        .fill(Color.adaptiveGray)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Image(systemName: "waveform")
                                .foregroundColor(.adaptiveWhite)
                                .frame(width: 8, height: 8)
                        )
                        .onTapGesture {
                            viewStore.send(.presentAudioFullScreen(true))
                        }
                        .fullScreenCover(isPresented: viewStore.binding(
                            get: \.presentAudioFullScreen,
                            send: AttachmentAddAudioAction.presentAudioFullScreen)
                        ) {
                            VStack {
                                HStack(spacing: 8) {
                                    Spacer()
                                    
                                    Button(action: {
                                        viewStore.send(.removeFullScreenAlertButtonTapped)
                                    }) {
                                        Image(systemName: "trash")
                                            .frame(width: 48, height: 48)
                                            .foregroundColor(.chambray)
                                    }
                                    
                                    Button(action: {
                                        viewStore.send(.processShare)
                                    }) {
                                        Image(systemName: "square.and.arrow.up")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(.chambray)
                                    }
                                    
                                    Button(action: {
                                        viewStore.send(.presentAudioFullScreen(false))
                                    }) {
                                        Image(systemName: "xmark")
                                            .frame(width: 48, height: 48)
                                            .foregroundColor(.chambray)
                                    }
                                }
                                
                                Spacer()
                                
                                Group {
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.black.opacity(0.08))
                                            .frame(height: 8)
                                        Capsule()
                                            .fill(Color.red)
                                            .frame(width: viewStore.playerProgress, height: 8)
                                            .animation(nil)
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
                                                Image(systemName: "gobackward.15")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 24, height: 24)
                                                    .foregroundColor(.chambray)
                                            })
                                            
                                            
                                            Button(action: {
                                                viewStore.send(.playButtonTapped)
                                            }, label: {
                                                Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 32, height: 32)
                                                    .foregroundColor(.chambray)
                                            })
                                            
                                            Button(action: {
                                                viewStore.send(.playerGoForward)
                                            }, label: {
                                                Image(systemName: "goforward.15")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 24, height: 24)
                                                    .foregroundColor(.chambray)
                                            })
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .padding()
                                .animation(.default)
                                .onAppear {
                                    viewStore.send(.onAppear)
                                }
                            }
                            .alert(
                                store.scope(state: \.removeFullScreenAlert),
                                dismiss: .cancelRemoveFullScreenAlert
                            )
                        }
                }
            }
        }
