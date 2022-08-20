//
//  CameraSettingsViewTests.swift
//  
//
//  Created by Albert Gil Escura on 22/8/21.
//

import XCTest
@testable import CameraFeature
import ComposableArchitecture
import AVCaptureDeviceClient

class CameraSettingsViewTests: XCTestCase {
    
    func testAppearanceAuthorizingCamera() {
//        var feedbackGeneratorCalled = false
        
        let store = TestStore(
            initialState: CameraState(cameraStatus: .notDetermined),
            reducer: cameraReducer,
            environment: CameraEnvironment(
                avCaptureDeviceClient: .init(
                    authorizationStatus: { .fireAndForget {} },
                    requestAccess: { Effect(value: true) }
                ),
                feedbackGeneratorClient: .init(
                    prepare: { .fireAndForget {} },
                    selectionChanged: {
//                        feedbackGeneratorCalled = true
                        return .fireAndForget {}
                    }
                ),
                applicationClient: .noop,
                mainQueue: .immediate
            )
        )
        
        store.send(.cameraButtonTapped)
//        {
//            XCTAssertTrue(feedbackGeneratorCalled)
//        }
        store.receive(.requestAccessResponse(true)) {
            $0.cameraStatus = .authorized
        }
    }
    
    func testAppearanceDenyingCamera() {
//        var feedbackGeneratorCalled = false
        
        let store = TestStore(
            initialState: CameraState(cameraStatus: .notDetermined),
            reducer: cameraReducer,
            environment: CameraEnvironment(
                avCaptureDeviceClient: .init(
                    authorizationStatus: { .fireAndForget {} },
                    requestAccess: { Effect(value: false) }
                ),
                feedbackGeneratorClient: .init(
                    prepare: { .fireAndForget {} },
                    selectionChanged: {
//                        feedbackGeneratorCalled = true
                        return .fireAndForget {}
                    }
                ),
                applicationClient: .noop,
                mainQueue: .immediate
            )
        )
        
        store.send(.cameraButtonTapped)
//        { _ in
//            XCTAssertTrue(feedbackGeneratorCalled)
//        }
        store.receive(.requestAccessResponse(false)) {
            $0.cameraStatus = .denied
        }
    }
    
    func testAppearanceAuthorized() {
        let store = TestStore(
            initialState: CameraState(cameraStatus: .authorized),
            reducer: cameraReducer,
            environment: CameraEnvironment(
                avCaptureDeviceClient: .init(
                    authorizationStatus: { .fireAndForget {} },
                    requestAccess: { Effect(value: true) }
                ),
                feedbackGeneratorClient: .noop,
                applicationClient: .noop,
                mainQueue: .immediate
            )
        )
        
        store.send(.cameraButtonTapped)
    }
    
    func testSnapshotAuthorized() {
        let store = Store(
            initialState: .init(cameraStatus: .authorized),
            reducer: cameraReducer,
            environment: .init(
                avCaptureDeviceClient: .noop,
                feedbackGeneratorClient: .noop,
                applicationClient: .noop,
                mainQueue: .unimplemented
            )
        )
        let view = CameraView(store: store)
        
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        
        assertSnapshot(matching: vc, as: .image)
    }
    
    func testSnapshot_GivenNotDetermined_WhenCameraButtonTapped_DeniedResponse() {
        let store = Store(
            initialState: .init(cameraStatus: .notDetermined),
            reducer: cameraReducer,
            environment: .init(
                avCaptureDeviceClient: .init(
                    authorizationStatus: { .fireAndForget {} },
                    requestAccess: { Effect(value: false) }
                ),
                feedbackGeneratorClient: .noop,
                applicationClient: .noop,
                mainQueue: .unimplemented
            )
        )
        let view = CameraView(store: store)
        
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        
        let viewStore = ViewStore(
            store.scope(state: { _ in () }),
            removeDuplicates: ==
        )
        
        assertSnapshot(matching: vc, as: .image)
        
        viewStore.send(.cameraButtonTapped)
        assertSnapshot(matching: vc, as: .image)
    }
    
    func testSnapshot_GivenNotDetermined_WhenCameraButtonTapped_Authorized() {
        let store = Store(
            initialState: .init(cameraStatus: .notDetermined),
            reducer: cameraReducer,
            environment: .init(
                avCaptureDeviceClient: .init(
                    authorizationStatus: { .fireAndForget {} },
                    requestAccess: { Effect(value: true) }
                ),
                feedbackGeneratorClient: .noop,
                applicationClient: .noop,
                mainQueue: .unimplemented
            )
        )
        let view = CameraView(store: store)
        
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        
        let viewStore = ViewStore(
            store.scope(state: { _ in () }),
            removeDuplicates: ==
        )
        
        assertSnapshot(matching: vc, as: .image)
        
        viewStore.send(.cameraButtonTapped)
        assertSnapshot(matching: vc, as: .image)
    }
}

import SwiftUI
import SnapshotTesting
