//
//  CameraSettingsViewTests.swift
//  
//
//  Created by Albert Gil Escura on 22/8/21.
//

import XCTest
@testable import SettingsFeature
import ComposableArchitecture
import AVCaptureDeviceClient

class CameraSettingsViewTests: XCTestCase {
    
    func testAppearanceAuthorizingCamera() {
        var feedbackGeneratorCalled = false
        
        let store = TestStore(
            initialState: CameraSettingsState(cameraStatus: .notDetermined),
            reducer: cameraSettingsReducer,
            environment: CameraSettingsEnvironment(
                avCaptureDeviceClient: .init(
                    authorizationStatus: { .fireAndForget {} },
                    requestAccess: { Effect(value: true) }
                ),
                feedbackGeneratorClient: .init(
                    prepare: { .fireAndForget {} },
                    selectionChanged: {
                        feedbackGeneratorCalled = true
                        return .fireAndForget {}
                    }
                ),
                applicationClient: .noop,
                mainQueue: .immediate
            )
        )
        
        store.send(.cameraSettingsButtonTapped) { _ in
            XCTAssertTrue(feedbackGeneratorCalled)
        }
        store.receive(.requestAccessResponse(true)) {
            $0.cameraStatus = .authorized
        }
    }
    
    func testAppearanceDenyingCamera() {
        var feedbackGeneratorCalled = false
        
        let store = TestStore(
            initialState: CameraSettingsState(cameraStatus: .notDetermined),
            reducer: cameraSettingsReducer,
            environment: CameraSettingsEnvironment(
                avCaptureDeviceClient: .init(
                    authorizationStatus: { .fireAndForget {} },
                    requestAccess: { Effect(value: false) }
                ),
                feedbackGeneratorClient: .init(
                    prepare: { .fireAndForget {} },
                    selectionChanged: {
                        feedbackGeneratorCalled = true
                        return .fireAndForget {}
                    }
                ),
                applicationClient: .noop,
                mainQueue: .immediate
            )
        )
        
        store.send(.cameraSettingsButtonTapped) { _ in
            XCTAssertTrue(feedbackGeneratorCalled)
        }
        store.receive(.requestAccessResponse(false)) {
            $0.cameraStatus = .denied
        }
    }
    
    func testAppearanceAuthorized() {
        let store = TestStore(
            initialState: CameraSettingsState(cameraStatus: .authorized),
            reducer: cameraSettingsReducer,
            environment: CameraSettingsEnvironment(
                avCaptureDeviceClient: .init(
                    authorizationStatus: { .fireAndForget {} },
                    requestAccess: { Effect(value: true) }
                ),
                feedbackGeneratorClient: .noop,
                applicationClient: .noop,
                mainQueue: .immediate
            )
        )
        
        store.send(.cameraSettingsButtonTapped)
    }
}
