//
//  MicrophoneView.swift
//  
//
//  Created by Albert Gil Escura on 26/8/21.
//

import ComposableArchitecture
import SwiftUI
import AVAudioSessionClient
import FeedbackGeneratorClient
import UIApplicationClient
import Localizables
import Styles
import Models

public struct MicrophoneState: Equatable {
    public var microphoneStatus: AudioRecordPermission
    
    public init(
        microphoneStatus: AudioRecordPermission
    ) {
        self.microphoneStatus = microphoneStatus
    }
}

extension AudioRecordPermission {
    public var title: String {
        switch self {
        case .authorized:
            return "microphone.authorized".localized
        case .denied:
            return "microphone.denied".localized
        case .notDetermined:
            return "microphone.notDetermined".localized
        }
    }
}

public enum MicrophoneAction: Equatable {
    case microphoneButtonTapped
    
    case requestAccessResponse(Bool)
    case goToSettings
}

public struct MicrophoneEnvironment {
    public let avAudioSessionClient: AVAudioSessionClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let applicationClient: UIApplicationClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init(
        avAudioSessionClient: AVAudioSessionClient,
        feedbackGeneratorClient: FeedbackGeneratorClient,
        applicationClient: UIApplicationClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.avAudioSessionClient = avAudioSessionClient
        self.feedbackGeneratorClient = feedbackGeneratorClient
        self.applicationClient = applicationClient
        self.mainQueue = mainQueue
    }
}

public let microphoneReducer = Reducer<
    MicrophoneState,
    MicrophoneAction,
    MicrophoneEnvironment
> { state, action, environment in
    switch action {
    case .microphoneButtonTapped:
        switch state.microphoneStatus {
        case .notDetermined:
            return .task { @MainActor in
                await  environment.feedbackGeneratorClient.selectionChanged()
                return .requestAccessResponse(try await environment.avAudioSessionClient.requestRecordPermission())
            }
            
        default:
            break
        }
        return .none

    case let .requestAccessResponse(authorized):
        state.microphoneStatus = authorized ? .authorized : .denied
        return .none
        
    case .goToSettings:
        guard state.microphoneStatus != .notDetermined else { return .none }
        return environment.applicationClient.openSettings()
            .fireAndForget()
    }
}

public struct MicrophoneView: View {
    let store: Store<MicrophoneState, MicrophoneAction>
    
    public init(
        store: Store<MicrophoneState, MicrophoneAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
            Form {
                Section(
                    footer:
                        Group {
                            if viewStore.microphoneStatus == .notDetermined || viewStore.microphoneStatus == .authorized || viewStore.microphoneStatus == .denied {
                                Text(viewStore.microphoneStatus.description)
                            } else {
                                Text(viewStore.microphoneStatus.description)
                                + Text(" ") +
                                Text("Settings.GoToSettings".localized)
                                    .underline()
                                    .foregroundColor(.blue)
                            }
                        }
                        .onTapGesture {
                            viewStore.send(.goToSettings)
                        }
                ) {
                    HStack {
                        Text(viewStore.microphoneStatus.title.localized)
                            .foregroundColor(.chambray)
                            .adaptiveFont(.latoRegular, size: 10)
                        Spacer()
                        if viewStore.microphoneStatus == .notDetermined {
                            Text("Settings.GivePermission".localized)
                                .foregroundColor(.adaptiveGray)
                                .adaptiveFont(.latoRegular, size: 8)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.adaptiveGray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.microphoneButtonTapped)
                    }
                }
            }
            .navigationBarTitle("Settings.Camera.Privacy".localized, displayMode: .inline)
        }
    }
}


extension AudioRecordPermission {
    public var description: String {
        switch self {
        case .authorized:
            return "microphone.authorized.description".localized
        case .denied:
            return "microphone.denied.description".localized
        case .notDetermined:
            return "microphone.notDetermined.description".localized
        }
    }
}
