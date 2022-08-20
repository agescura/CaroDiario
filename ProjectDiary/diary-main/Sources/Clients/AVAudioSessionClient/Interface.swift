//
//  Interface.swift
//  
//
//  Created by Albert Gil Escura on 26/8/21.
//

import ComposableArchitecture
import AVFoundation
import Models

public struct AVAudioSessionClient {
    public var recordPermission: () -> AudioRecordPermission
    public var requestRecordPermission: () async throws -> Bool
    
    public init(
        recordPermission: @escaping () -> AudioRecordPermission,
        requestRecordPermission: @escaping () async throws -> Bool
    ) {
        self.recordPermission = recordPermission
        self.requestRecordPermission = requestRecordPermission
    }
}

extension AVAudioSession.RecordPermission {
    public var permission: AudioRecordPermission {
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
