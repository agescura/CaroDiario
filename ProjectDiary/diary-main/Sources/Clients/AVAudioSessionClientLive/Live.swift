//
//  Live.swift
//  
//
//  Created by Albert Gil Escura on 26/8/21.
//

import ComposableArchitecture
import AVFoundation
import AVAudioSessionClient

extension AVAudioSessionClient {
    public static var live: Self = {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            print("AVAudioSession configuration error: \(error.localizedDescription)")
        }
        
        return Self(
            recordPermission: { session.recordPermission.permission },
            requestRecordPermission: {
                try await withCheckedThrowingContinuation { continuation in
                    session.requestRecordPermission { granted in
                        continuation.resume(with: .success(granted))
                    }
                }
            }
        )
    }()
}
