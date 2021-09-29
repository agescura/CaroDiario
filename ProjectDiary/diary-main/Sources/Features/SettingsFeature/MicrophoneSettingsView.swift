//
//  MicrophoneSettingsView.swift
//  
//
//  Created by Albert Gil Escura on 26/8/21.
//

import ComposableArchitecture
import SwiftUI
import AVAudioSessionClient
import FeedbackGeneratorClient
import UIApplicationClient

public struct MicrophoneSettingsState: Equatable {
    public var microphoneStatus: AVAudioSessionClient.AudioRecordPermission
}

public enum MicrophoneSettingsAction: Equatable {
    case microphoneSettingsButtonTapped
    
    case requestAccessResponse(Bool)
    case goToSettings
}

public struct MicrophoneSettingsEnvironment {
    public let avAudioSessionClient: AVAudioSessionClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let applicationClient: UIApplicationClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
}

let microphoneSettingsReducer = Reducer<MicrophoneSettingsState, MicrophoneSettingsAction, MicrophoneSettingsEnvironment> { state, action, environment in
    switch action {
    case .microphoneSettingsButtonTapped:
        switch state.microphoneStatus {
        case .notDetermined:
            return .merge(
                environment.avAudioSessionClient.requestRecordPermission()
                    .receive(on: environment.mainQueue)
                    .eraseToEffect()
                    .map(MicrophoneSettingsAction.requestAccessResponse),
                environment.feedbackGeneratorClient.selectionChanged()
                    .fireAndForget()
            )
            
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

public struct MicrophoneSettingsView: View {
    let store: Store<MicrophoneSettingsState, MicrophoneSettingsAction>
    
    public var body: some View {
        WithViewStore(store) { viewStore in
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
                        viewStore.send(.microphoneSettingsButtonTapped)
                    }
                }
            }
            .navigationBarTitle("Settings.Camera.Privacy".localized, displayMode: .inline)
        }
    }
}


extension AVAudioSessionClient.AudioRecordPermission {
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
