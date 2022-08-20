//
//  CameraView.swift
//  
//
//  Created by Albert Gil Escura on 8/8/21.
//

import SwiftUI
import ComposableArchitecture
import AVCaptureDeviceClient
import UIApplicationClient
import FeedbackGeneratorClient
import Localizables
import Styles
import Models

public struct CameraState: Equatable {
    public var cameraStatus: AuthorizedVideoStatus
    
    public init(
        cameraStatus: AuthorizedVideoStatus
    ) {
        self.cameraStatus = cameraStatus
    }
}

public enum CameraAction: Equatable {
    case cameraButtonTapped
    
    case requestAccessResponse(Bool)
    case goToSettings
}

public struct CameraEnvironment {
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

public let cameraReducer = Reducer<
    CameraState,
    CameraAction,
    CameraEnvironment
> { state, action, environment in
    switch action {
    case .cameraButtonTapped:
        switch state.cameraStatus {
        case .notDetermined:
            return .task {
                await environment.feedbackGeneratorClient.selectionChanged()
                return .requestAccessResponse(await environment.avCaptureDeviceClient.requestAccess())
            }
            
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

public struct CameraView: View {
    let store: Store<CameraState, CameraAction>
    
    public init(
        store: Store<CameraState, CameraAction>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store) { viewStore in
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
                        viewStore.send(.cameraButtonTapped)
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
