//
//  AudioRecordView.swift
//  
//
//  Created by Albert Gil Escura on 26/8/21.
//

import ComposableArchitecture
import SwiftUI
import AVAudioRecorderClient
import AVAudioSessionClient
import AVAudioPlayerClient
import Views
import UIApplicationClient
import Styles
import FileClient
import Localizables
import SwiftHelper
import Models

public struct AudioRecordState: Equatable {
    public var audioRecordPermission: AudioRecordPermission
    
    public var isRecording: Bool = false
    public var audioPath: URL?
    public var audioRecordDuration: TimeInterval = .init()
    public var hasAudioRecorded: Bool = false
    
    public var showRecordAlert: Bool = false
    public var recordAlert: AlertState<AudioRecordAction>?
    
    var isPlaying: Bool = false
    var playerDuration: Double = 0
    var isPlayerDragging: Bool = false
    var isDragging = false
    var playerProgress: CGFloat = 0
    var playerProgressTime: Double = 0
    
    public var showDismissAlert: Bool = false
    public var dismissAlert: AlertState<AudioRecordAction>?
    
    
    public init(
        audioRecordPermission: AudioRecordPermission = .notDetermined
    ) {
        self.audioRecordPermission = audioRecordPermission
    }
}

public enum AudioRecordAction: Equatable {
    case onAppear
    case requestMicrophonePermissionButtonTapped
    case requestMicrophonePermissionResponse(Bool)
    case goToSettings
    
    case recorderPlayer(AVAudioRecorderClient.Action)
    case audioPlayer(AVAudioPlayerClient.Action)
    
    case recordButtonTapped
    case record
    case stopRecording
    case removeRecording
    case startRecorderTimer
    case resetRecorderTimer
    case addSecondRecorderTimer
    
    case recordAlertButtonTapped
    case recordCancelAlert
    
    case playButtonTapped
    case isPlayingResponse(Bool)
    case playerProgressAddTimer
    case playerProgressResponse(Double)
    case dragOnChanged(CGPoint)
    case dragOnEnded(CGPoint)
    case playerGoBackward
    case playerGoForward
    case removeAudioRecord
    
    case dismissAlertButtonTapped
    case dismissCancelAlert
    case dismiss
    
    case addAudio
}

extension AudioRecordPermission {
    var description: String {
        switch self {
        case .authorized:
            return "AudioRecord.Authorized".localized
        case .denied:
            return "AudioRecord.Denied".localized
        case .notDetermined:
            return "AudioRecord.NotDetermined".localized
        }
    }
}

public struct AudioRecordEnvironment {
    public let fileClient: FileClient
    public var applicationClient: UIApplicationClient
    public var avAudioSessionClient: AVAudioSessionClient
    public var avAudioPlayerClient: AVAudioPlayerClient
    public var avAudioRecorderClient: AVAudioRecorderClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    public let date: () -> Date
    public let uuid: () -> UUID
    
    public init(
        fileClient: FileClient,
        applicationClient: UIApplicationClient,
        avAudioSessionClient: AVAudioSessionClient,
        avAudioPlayerClient: AVAudioPlayerClient,
        avAudioRecorderClient: AVAudioRecorderClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        date: @escaping () -> Date,
        uuid: @escaping () -> UUID
    ) {
        self.fileClient = fileClient
        self.applicationClient = applicationClient
        self.avAudioSessionClient = avAudioSessionClient
        self.avAudioPlayerClient = avAudioPlayerClient
        self.avAudioRecorderClient = avAudioRecorderClient
        self.mainQueue = mainQueue
        self.date = date
        self.uuid = uuid
    }
}

public let audioRecordReducer = Reducer<AudioRecordState, AudioRecordAction, AudioRecordEnvironment> { state, action, environment in
    
    struct RecorderManagerId: Hashable {}
    struct RecorderTimerId: Hashable {}
    struct PlayerManagerId: Hashable {}
    struct PlayerTimerId: Hashable {}
    
    switch action {
    
    case .onAppear:
        state.audioRecordPermission = environment.avAudioSessionClient.recordPermission()
        return environment.avAudioRecorderClient.create(id: RecorderManagerId())
            .map(AudioRecordAction.recorderPlayer)
        
    case .requestMicrophonePermissionButtonTapped:
        return .task { @MainActor in
            return .requestMicrophonePermissionResponse(try await environment.avAudioSessionClient.requestRecordPermission())
        }
        
    case let .requestMicrophonePermissionResponse(response):
        state.audioRecordPermission = response ? .authorized : .denied
        return .none
        
    case .goToSettings:
        return environment.applicationClient.openSettings()
            .fireAndForget()
        
    case let .recorderPlayer(.didFinishRecording(successfully: value)):
        state.isRecording = false
        return .none
        
    case .recorderPlayer:
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
        
    case .recordButtonTapped:
        if state.isRecording {
            return Effect(value: .stopRecording)
        } else {
            if state.hasAudioRecorded {
                return Effect(value: .recordAlertButtonTapped)
            } else {
                return Effect(value: .record)
            }
        }
        
    case .record:
        let id = environment.uuid()
        state.audioPath = environment.fileClient.path(id).appendingPathExtension("caf")
        guard let audioPath = state.audioPath else { return .none }
        
        state.hasAudioRecorded = false
        state.isRecording = true
        return .merge(
            environment.avAudioRecorderClient.record(id: RecorderManagerId(), url: audioPath)
                .fireAndForget(),
            Effect(value: .startRecorderTimer)
        )
        
    case .stopRecording:
        guard let audioPath = state.audioPath else { return .none }
        
        state.isRecording = false
        state.hasAudioRecorded = true
        return .merge(
            environment.avAudioRecorderClient.stop(id: RecorderManagerId())
                .fireAndForget(),
            .cancel(id: RecorderTimerId()),
            environment.avAudioPlayerClient.create(id: PlayerManagerId(), url: audioPath)
                .map(AudioRecordAction.audioPlayer)
        )
        
    case .removeRecording:
        state.hasAudioRecorded = false
        
        return .merge(
            environment.avAudioRecorderClient.destroy(id: RecorderManagerId())
                .fireAndForget(),
            Effect(value: .resetRecorderTimer)
        )
        
    case .startRecorderTimer:
        state.audioRecordDuration = 0
        return Effect.timer(id: RecorderTimerId(), every: 1, on: environment.mainQueue.animation())
            .map { _ in .addSecondRecorderTimer }
        
    case .resetRecorderTimer:
        state.audioRecordDuration = 0
        return .cancel(id: RecorderTimerId())
        
    case .addSecondRecorderTimer:
        state.audioRecordDuration += 1
        return .none
        
    case .recordAlertButtonTapped:
        state.recordAlert = .init(
            title: .init("AudioRecord.Alert".localized),
            message: .init("AudioRecord.Alert.Message".localized),
            primaryButton: .cancel(.init("Cancel".localized), action: .send(.recordCancelAlert)),
            secondaryButton: .destructive(.init("Continue".localized), action: .send(.record))
        )
        return .none
        
    case .recordCancelAlert:
        state.recordAlert = nil
        return .none
        
    case .playButtonTapped:
        return environment.avAudioPlayerClient.isPlaying(id: PlayerManagerId())
            .map(AudioRecordAction.isPlayingResponse)
        
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
            .map(AudioRecordAction.playerProgressResponse)
        
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
        
    case .removeAudioRecord:
        state.hasAudioRecorded = false
        state.audioRecordDuration = 0
        return .none
        
    case .dismissAlertButtonTapped:
        guard state.showDismissAlert else { return Effect(value: .dismiss) }
        
        state.dismissAlert = .init(
            title: .init("Title"),
            message: .init("Message"),
            primaryButton: .cancel(.init("Cancel".localized), action: .send(.dismissCancelAlert)),
            secondaryButton: .destructive(.init("Si, descartar."), action: .send(.dismiss))
        )
        return .none
        
    case .dismissCancelAlert:
        state.dismissAlert = nil
        return .none
        
    case .dismiss:
        return .merge(
            environment.avAudioRecorderClient.destroy(id: RecorderManagerId())
                .fireAndForget(),
            environment.avAudioPlayerClient.destroy(id: PlayerManagerId())
                .fireAndForget()
        )
        
    case .addAudio:
        return .none
    }
}

public struct AudioRecordView: View {
    let store: Store<AudioRecordState, AudioRecordAction>
    
    public init(
        store: Store<AudioRecordState, AudioRecordAction>
    ) {
        self.store = store
    }
    
    @State var rounded = false
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack(spacing: 16) {
                
                HStack(spacing: 24) {
                    Spacer()
                    
                    Button(action: {
                        viewStore.send(.dismiss)
                    }, label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 16, height: 16)
                            .foregroundColor(.chambray)
                    })
                }
                
                Spacer()
                
                switch viewStore.audioRecordPermission {
                
                case .notDetermined:
                    Text(viewStore.audioRecordPermission.description)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.chambray)
                        .adaptiveFont(.latoRegular, size: 14)
                    Spacer()
                    PrimaryButtonView(
                        label: { Text("AudioRecord.AllowMicrophone".localized) },
                        action: { viewStore.send(.requestMicrophonePermissionButtonTapped) }
                    )
                    
                case .denied:
                    Text(viewStore.audioRecordPermission.description)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.chambray)
                        .adaptiveFont(.latoRegular, size: 14)
                    Spacer()
                    PrimaryButtonView(
                        label: { Text("AudioRecord.GoToSettings".localized) },
                        action: { viewStore.send(.goToSettings) }
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
                            
                            Button(action: {
                                viewStore.send(.removeAudioRecord)
                            }, label: {
                                Image(systemName: "trash")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.chambray)
                            })
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
                        action: {
                            viewStore.send(.recordButtonTapped)
                        }
                    )
                    
                    Text("AudioRecord.StartRecording".localized)
                        .multilineTextAlignment(.center)
                        .adaptiveFont(.latoRegular, size: 10)
                        .foregroundColor(.adaptiveGray)
                    
                    Spacer()
                    
                    PrimaryButtonView(
                        label: { Text("AudioRecord.Add".localized) },
                        disabled: !viewStore.hasAudioRecorded,
                        inFlight: false,
                        action: {
                            viewStore.send(.addAudio)
                        }
                    )
                }
            }
            .padding()
            .onAppear {
                viewStore.send(.onAppear)
            }
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
