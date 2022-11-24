//
//  AudioRecordFeatureTests.swift
//  
//
//  Created by Albert Gil Escura on 29/8/21.
//

import XCTest
import ComposableArchitecture
@testable import AudioRecordFeature
import AVAudioSessionClient

@MainActor
class AudioRecordFeatureTests: XCTestCase {
    func testCreateAndDestroyAudioDependencies() {
        var audioRecorderCreateCalled = false
        
        let store = TestStore(
            initialState: AudioRecordState(),
            reducer: audioRecordReducer,
            environment: AudioRecordEnvironment(
                fileClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .noop,
                avAudioPlayerClient: .init(
                    create: { _, _ in .fireAndForget {} },
                    destroy: { _ in .fireAndForget {} },
                    play: { _ in .fireAndForget {} },
                    stop: { _ in .fireAndForget {} }
                ),
                avAudioRecorderClient: .init(
                    create: { _ in
                        audioRecorderCreateCalled = true
                        return .fireAndForget {}
                    },
                    destroy: { _ in .fireAndForget {} },
                    record: { _, _ in .fireAndForget {} },
                    stop: { _ in .fireAndForget {} }
                ),
                mainQueue: .immediate,
                date: Date.init,
                uuid: UUID.init
            )
        )
        
        store.send(.onAppear)
    }
    
    func testRequestPermissionsResponseDenied() async {
        var openSettingsCalled = false
        
        let store = TestStore(
            initialState: AudioRecordState(),
            reducer: audioRecordReducer,
            environment: AudioRecordEnvironment(
                fileClient: .noop,
                applicationClient: .init(
                    alternateIconName: nil,
                    setAlternateIconName: { _ in () },
                    supportsAlternateIcons: { false },
                    openSettings: {
                        openSettingsCalled = true
                        return .fireAndForget {}
                    },
                    open: { _,_  in .fireAndForget {} },
                    canOpen: { _ in false },
                    share: { _, _ in .fireAndForget {} },
                    showTabView: { _ in .fireAndForget {} }
                ),
                avAudioSessionClient: .init(
                    recordPermission: { .notDetermined },
                    requestRecordPermission: { false }
                ),
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                mainQueue: .immediate,
                date: Date.init,
                uuid: UUID.init
            )
        )

        await store.send(.requestMicrophonePermissionButtonTapped)
        await store.receive(.requestMicrophonePermissionResponse(false)) {
            $0.audioRecordPermission = .denied
        }

        await store.send(.goToSettings)
    }

    func testRequestPermissionsResponseAuthorized() async {
        let store = TestStore(
            initialState: AudioRecordState(),
            reducer: audioRecordReducer,
            environment: AudioRecordEnvironment(
                fileClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .init(
                    recordPermission: { .notDetermined },
                    requestRecordPermission: { true }
                ),
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                mainQueue: .immediate,
                date: Date.init,
                uuid: UUID.init
            )
        )

        await store.send(.requestMicrophonePermissionButtonTapped)
        await store.receive(.requestMicrophonePermissionResponse(true)) {
            $0.audioRecordPermission = .authorized
        }
    }
    
    func testRecordAudioAndPlay() async {
        var audioPlayerIsPlaying = false
        
        let store = TestStore(
            initialState: AudioRecordState(),
            reducer: audioRecordReducer,
            environment: AudioRecordEnvironment(
                fileClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .init(
                    recordPermission: { .notDetermined },
                    requestRecordPermission: { false }
                ),
                avAudioPlayerClient: .init(
                    create: { _, _ in .fireAndForget {}},
                    destroy: { _ in .fireAndForget {}},
                    duration: { _ in .fireAndForget {}},
                    play: { _ in
                        audioPlayerIsPlaying = true
                        return .fireAndForget {}
                    },
                    pause: { _ in
                        audioPlayerIsPlaying = false
                        return .fireAndForget {}
                    },
                    stop: { _ in
                        audioPlayerIsPlaying = false
                        return .fireAndForget {}
                    },
                    isPlaying: { _ in
                        return Effect(value: audioPlayerIsPlaying)
                    },
                    currentTime: { _ in .fireAndForget {}},
                    setCurrentTime: { _, _ in .fireAndForget {}}
                ),
                avAudioRecorderClient: .init(
                    create: { _ in .fireAndForget {}},
                    destroy: { _ in .fireAndForget {}},
                    record: { _, _ in .fireAndForget {}},
                    stop: { _ in .fireAndForget {}}
                ),
                mainQueue: .immediate,
                date: Date.init,
                uuid: UUID.init
            )
        )
        
        await store.send(.onAppear)
        await store.send(.recordButtonTapped)
        await store.receive(.record) {
            $0.isRecording = true
            $0.audioPath = URL(string: "www.apple.com.caf")
        }
        await store.receive(.startRecorderTimer)
        await store.receive(.addSecondRecorderTimer) {
            $0.audioRecordDuration = 1.0
        }
        
        await store.send(.recordButtonTapped)
        await store.receive(.stopRecording) {
            $0.isRecording = false
            $0.hasAudioRecorded = true
        }
        
        await store.send(.playButtonTapped)
        await store.receive(.isPlayingResponse(false)) {
            $0.isPlaying = true
        }
        
        await store.send(.playButtonTapped)
        await store.receive(.isPlayingResponse(true)) {
            $0.isPlaying = false
        }
    }
}
