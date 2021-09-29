//
//  Interface.swift
//  
//
//  Created by Albert Gil Escura on 26/8/21.
//

import ComposableArchitecture
import AVFoundation

public struct AVAudioSessionClient {
    
    public enum AudioRecordPermission {
        case authorized
        case denied
        case notDetermined
    }
    
    public var recordPermission: AudioRecordPermission
    public var requestRecordPermission: () -> Effect<Bool, Never>
    
    public init(
        recordPermission: AudioRecordPermission,
        requestRecordPermission: @escaping () -> Effect<Bool, Never>
    ) {
        self.recordPermission = recordPermission
        self.requestRecordPermission = requestRecordPermission
    }
}

extension AVAudioSession.RecordPermission {
    
    public var permission: AVAudioSessionClient.AudioRecordPermission {
        switch self {
        case .granted:
            return .authorized
        case .denied:
            return .denied
        case .undetermined:
            fallthrough
        @unknown default:
            return .notDetermined
        }
    }
}
