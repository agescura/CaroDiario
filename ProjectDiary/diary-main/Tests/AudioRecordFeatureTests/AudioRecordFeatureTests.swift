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
import Combine

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
                mainRunLoop: .immediate,
                uuid: UUID.init
            )
        )
        
        store.send(.onAppear) { _ in
            XCTAssertTrue(audioRecorderCreateCalled)
        }
    }
    
    func testRequestPermissionsResponseDenied() {
        var openSettingsCalled = false
        
        let store = TestStore(
            initialState: AudioRecordState(),
            reducer: audioRecordReducer,
            environment: AudioRecordEnvironment(
                fileClient: .noop,
                applicationClient: .init(
                    alternateIconName: nil,
                    setAlternateIconName: { _ in .fireAndForget {} },
                    supportsAlternateIcons: { false },
                    openSettings: {
                        openSettingsCalled = true
                        return .fireAndForget {}
                    },
                    open: { _ in .fireAndForget {} },
                    share: { _ in .fireAndForget {} }
                ),
                avAudioSessionClient: .init(
                    recordPermission: .notDetermined,
                    requestRecordPermission: { Effect(value: false) }
                ),
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                mainQueue: .immediate,
                mainRunLoop: .immediate,
                uuid: UUID.init
            )
        )

        store.send(.requestMicrophonePermissionButtonTapped)
        store.receive(.requestMicrophonePermissionResponse(false)) {
            $0.audioRecordPermission = .denied
        }

        store.send(.goToSettings) { _ in
            XCTAssertTrue(openSettingsCalled)
        }
    }

    func testRequestPermissionsResponseAuthorized() {
        let store = TestStore(
            initialState: AudioRecordState(),
            reducer: audioRecordReducer,
            environment: AudioRecordEnvironment(
                fileClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .init(
                    recordPermission: .notDetermined,
                    requestRecordPermission: { Effect(value: true) }
                ),
                avAudioPlayerClient: .noop,
                avAudioRecorderClient: .noop,
                mainQueue: .immediate,
                mainRunLoop: .immediate,
                uuid: UUID.init
            )
        )

        store.send(.requestMicrophonePermissionButtonTapped)
        store.receive(.requestMicrophonePermissionResponse(true)) {
            $0.audioRecordPermission = .authorized
        }
    }
    
    func testRecordAudioAndPlay() {
        var audioPlayerIsPlaying = false
        
        let store = TestStore(
            initialState: AudioRecordState(),
            reducer: audioRecordReducer,
            environment: AudioRecordEnvironment(
                fileClient: .noop,
                applicationClient: .noop,
                avAudioSessionClient: .init(
                    recordPermission: .notDetermined,
                    requestRecordPermission: { Effect(value: true) }
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
                mainRunLoop: .immediate,
                uuid: UUID.init
            )
        )
        
        store.send(.onAppear)
        store.send(.recordButtonTapped)
        store.receive(.record) {
            $0.isRecording = true
            $0.audioPath = URL(string: "www.apple.com")
        }
        store.receive(.startRecorderTimer)
        
        store.send(.recordButtonTapped)
        store.receive(.stopRecording) {
            $0.isRecording = false
            $0.hasAudioRecorded = true
        }
        
        store.send(.playButtonTapped)
        store.receive(.isPlayingResponse(false)) {
            $0.isPlaying = true
        }
        
        store.send(.playButtonTapped)
        store.receive(.isPlayingResponse(true)) {
            $0.isPlaying = false
        }
    }
//
//    func testRecordAudioAndPlay() {
//        var audioRecorderRecordCalled = false
//        var audioRecorderStopCalled = false
//        var audioPlayerPlayCalled = false
//        var audioPlayerStopCalled = false
//        let mainQueue: AnySchedulerOf<DispatchQueue> = .immediate
//
//        let recorderStopSubject = PassthroughSubject<Void, Never>()
//        let playerStopSubject = PassthroughSubject<Void, Never>()
//        var bag1 = Set<AnyCancellable>()
//        var bag2 = Set<AnyCancellable>()
//
//        let store = TestStore(
//            initialState: AudioRecordState(audioRecordPermission: .authorized),
//            reducer: audioRecordReducer,
//            environment: AudioRecordEnvironment(
//                applicationClient: .noop,
//                avAudioSessionClient: .init(
//                    recordPermission: .authorized,
//                    requestRecordPermission: { .fireAndForget {} }
//                ),
//                avAudioPlayerClient: .init(
//                    create: { _ in
//                        .future { callback in
//                            playerStopSubject
//                                .receive(on: mainQueue)
//                                .sink(receiveValue: {
//                                    callback(.success(.didFinishPlaying(successfully: true)))
//                            })
//                            .store(in: &bag1)
//                        }
//
//                    },
//                    destroy: { _ in
//                        playerStopSubject.send(completion: .finished)
//                        return .fireAndForget {}
//                    },
//                    play: { _, _ in
//                        audioPlayerPlayCalled = true
//                        return .fireAndForget {}
//                    },
//                    stop: { _ in
//                        audioPlayerStopCalled = true
//                        playerStopSubject.send()
//                        return .fireAndForget {}
//                    }
//                ),
//                avAudioRecorderClient: .init(
//                    create: { _ in
//                        .future { callback in
//                            recorderStopSubject
//                                .receive(on: mainQueue)
//                                .sink(receiveValue: {
//                                    callback(.success(.didFinishRecording(successfully: true)))
//                            })
//                            .store(in: &bag2)
//                        }
//
//                    },
//                    destroy: { _ in
//                        recorderStopSubject.send(completion: .finished)
//                        return .fireAndForget {}
//                    },
//                    record: { _, _ in
//                        audioRecorderRecordCalled = true
//                        return .fireAndForget {}
//                    },
//                    stop: { _ in
//                        audioRecorderStopCalled = true
//                        recorderStopSubject.send()
//                        return .fireAndForget {}
//                    }
//                ),
//                mainQueue: mainQueue,
//                mainRunLoop: .immediate
//            )
//        )
//
//        store.send(.onAppear)
//
//        store.send(.recordButtonTapped) {
//            $0.recordButtonState = .recording
//        }
//        store.receive(.record) { _ in
//            XCTAssertTrue(audioRecorderRecordCalled)
//        }
//        store.receive(.startTimer)
//        store.send(.stopRecording) {
//            XCTAssertTrue(audioRecorderStopCalled)
//            $0.playButtonState = .stop
//            $0.recordButtonState = .recorded
//        }
//        store.receive(.recorderPlayer(.didFinishRecording(successfully: true))) {
//            $0.playButtonState = .stop
//        }
//        store.receive(.resetTimer)
//        store.send(.playButtonTapped)
//        store.receive(.play) {
//            XCTAssertTrue(audioPlayerPlayCalled)
//            $0.playButtonState = .play
//        }
//
//        store.receive(.startTimer)
//        store.send(.stopPlaying) {
//            $0.playButtonState = .stop
//            XCTAssertTrue(audioPlayerStopCalled)
//        }
//        store.receive(.audioPlayer(.didFinishPlaying(successfully: true)))
//        store.receive(.resetTimer)
//
//        store.send(.onDissapear)
//    }
}
