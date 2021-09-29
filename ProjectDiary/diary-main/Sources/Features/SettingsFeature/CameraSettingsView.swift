//
//  CameraSettingsView.swift
//  
//
//  Created by Albert Gil Escura on 8/8/21.
//

import SwiftUI
import ComposableArchitecture
import AVCaptureDeviceClient
import UIApplicationClient
import FeedbackGeneratorClient

public struct CameraSettingsState: Equatable {
    public var cameraStatus: AuthorizedVideoStatus
}

public enum CameraSettingsAction: Equatable {
    case cameraSettingsButtonTapped
    
    case requestAccessResponse(Bool)
    case goToSettings
}

public struct CameraSettingsEnvironment {
    public let avCaptureDeviceClient: AVCaptureDeviceClient
    public let feedbackGeneratorClient: FeedbackGeneratorClient
    public let applicationClient: UIApplicationClient
    public let mainQueue: AnySchedulerOf<DispatchQueue>
    
    public init(
        avCaptureDeviceClient: AVCaptureDeviceClient,
        feedbackGeneratorClient: FeedbackGeneratorClient,
        applicationClient: UIApplicationClient,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.avCaptureDeviceClient = avCaptureDeviceClient
        self.feedbackGeneratorClient = feedbackGeneratorClient
        self.applicationClient = applicationClient
        self.mainQueue = mainQueue
    }
}

public let cameraSettingsReducer = Reducer<CameraSettingsState, CameraSettingsAction, CameraSettingsEnvironment> { state, action, environment in
    switch action {
    case .cameraSettingsButtonTapped:
        switch state.cameraStatus {
        case .notDetermined:
            return .merge(
                environment.avCaptureDeviceClient.requestAccess()
                    .map(CameraSettingsAction.requestAccessResponse),
                environment.feedbackGeneratorClient.selectionChanged()
                    .fireAndForget()
            )
            
        default:
            break
        }
        return .none
        
    case let .requestAccessResponse(authorized):
        state.cameraStatus = authorized ? .authorized : .denied
        return .none
        
    case .goToSettings:
        guard state.cameraStatus != .notDetermined else { return .none }
        return environment.applicationClient.openSettings()
            .fireAndForget()
    }
}

public struct CameraSettingsView: View {
    let store: Store<CameraSettingsState, CameraSettingsAction>
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                Section(
                    footer:
                        Group {
                            if viewStore.cameraStatus == .notDetermined || viewStore.cameraStatus == .authorized || viewStore.cameraStatus == .restricted {
                                Text(viewStore.cameraStatus.description)
                            } else {
                                Text(viewStore.cameraStatus.description)
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
                        Text(viewStore.cameraStatus.rawValue.localized)
                            .foregroundColor(.chambray)
                            .adaptiveFont(.latoRegular, size: 10)
                        Spacer()
                        if viewStore.cameraStatus == .notDetermined {
                            Text(viewStore.cameraStatus.permission)
                                .foregroundColor(.adaptiveGray)
                                .adaptiveFont(.latoRegular, size: 12)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.adaptiveGray)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewStore.send(.cameraSettingsButtonTapped)
                    }
                }
            }
            .navigationBarTitle("Settings.Camera.Privacy".localized, displayMode: .inline)
        }
    }
}

extension AuthorizedVideoStatus {
    
    var description: String {
        switch self {
        
        case .notDetermined:
            return "notDetermined.description".localized
        case .denied:
            return "denied.description".localized
        case .authorized:
            return "authorized.description".localized
        case .restricted:
            return "restricted.description".localized
        }
    }
    
    var permission: String {
        switch self {
        case .notDetermined:
            return "Settings.GivePermission".localized
        default:
            return ""
        }
    }
}
