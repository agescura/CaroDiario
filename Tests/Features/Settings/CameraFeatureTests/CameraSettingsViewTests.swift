import XCTest
@testable import CameraFeature
import ComposableArchitecture
import AVCaptureDeviceClient

@MainActor
class CameraSettingsViewTests: XCTestCase {
	
	func testAppearanceAuthorizingCamera() async {
		var feedbackGeneratorCalled = false
		
		let store = TestStore(
			initialState: CameraFeature.State(
				cameraStatus: .notDetermined
			),
			reducer: CameraFeature()
		) {
			$0.feedbackGeneratorClient.selectionChanged = {
				feedbackGeneratorCalled = true
			}
			$0.avCaptureDeviceClient.requestAccess = { true }
		}
		
		await store.send(.cameraButtonTapped)
		await store.receive(.requestAccessResponse(true)) {
			XCTAssertTrue(feedbackGeneratorCalled)
			$0.cameraStatus = .authorized
		}
	}
	
	func testAppearanceDenyingCamera() async {
		var feedbackGeneratorCalled = false
		
		let store = TestStore(
			initialState: CameraFeature.State(
				cameraStatus: .notDetermined
			),
			reducer: CameraFeature()
		) {
			$0.feedbackGeneratorClient.selectionChanged = {
				feedbackGeneratorCalled = true
			}
			$0.avCaptureDeviceClient.requestAccess = { false }
		}
		
		await store.send(.cameraButtonTapped)
		await store.receive(.requestAccessResponse(false)) {
			XCTAssertTrue(feedbackGeneratorCalled)
			$0.cameraStatus = .denied
		}
	}
	
	func testSnapshotAuthorized() {
		let store = Store(
			initialState: CameraFeature.State(
				cameraStatus: .authorized
			),
			reducer: CameraFeature()
		)
		let view = CameraView(store: store)
		
		let vc = UIHostingController(rootView: view)
		vc.view.frame = UIScreen.main.bounds
		
		assertSnapshot(matching: vc, as: .image)
	}
	
	func testSnapshot_GivenNotDetermined_WhenCameraButtonTapped_DeniedResponse() {
		let store = Store(
			initialState: CameraFeature.State(
				cameraStatus: .authorized
			),
			reducer: CameraFeature()
		)
		let view = CameraView(store: store)
		
		let vc = UIHostingController(rootView: view)
		vc.view.frame = UIScreen.main.bounds
		
		let viewStore = ViewStore(
			store,
			removeDuplicates: ==
		)
		
		assertSnapshot(matching: vc, as: .image)
		
		viewStore.send(.cameraButtonTapped)
		assertSnapshot(matching: vc, as: .image)
	}
	
	func testSnapshot_GivenNotDetermined_WhenCameraButtonTapped_Authorized() {
		let store = Store(
		  initialState: CameraFeature.State(
			  cameraStatus: .authorized
		  ),
		  reducer: CameraFeature()
		)
		let view = CameraView(store: store)
		
		let vc = UIHostingController(rootView: view)
		vc.view.frame = UIScreen.main.bounds
		
		let viewStore = ViewStore(
			store,
			removeDuplicates: ==
		)
		
		assertSnapshot(matching: vc, as: .image)
		
		viewStore.send(.cameraButtonTapped)
		assertSnapshot(matching: vc, as: .image)
	}
}

import SwiftUI
import SnapshotTesting
