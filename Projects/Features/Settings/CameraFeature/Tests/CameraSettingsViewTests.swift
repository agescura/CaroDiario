import AVCaptureDeviceClient
@testable import CameraFeature
import ComposableArchitecture
import Models
import SnapshotTesting
import SwiftUI
import TestUtils
import XCTest

@MainActor
final class CameraSettingsViewTests: XCTestCase {
	@MainActor
	func testAppearanceAuthorizingCamera() async {
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
		let store = TestStore(
			initialState: CameraFeature.State(),
			reducer: { CameraFeature() }
		) {
			$0.avCaptureDeviceClient.requestAccess = { true }
		}
		
		await store.send(\.view.task)
		
		await store.receive(\.requestAccessResponse, true) {
			$0.userSettings.authorizedVideoStatus = .authorized
		}
	}
	
	@MainActor
	func testAppearanceDenyingCamera() async {
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
		let store = TestStore(
			initialState: CameraFeature.State(),
			reducer: { CameraFeature() }
		) {
			$0.avCaptureDeviceClient.requestAccess = { false }
			$0.applicationClient.openSettings = {}
		}
		
		await store.send(\.view.task)
		
		await store.receive(\.requestAccessResponse, false) {
			$0.userSettings.authorizedVideoStatus = .denied
		}
		
		await store.send(\.view.goToSettings)
	}

	@MainActor
	func testAppearanceAuthorized() async {
		@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
		userSettings.authorizedVideoStatus = .denied
		
		let store = TestStore(
			initialState: CameraFeature.State(),
			reducer: { CameraFeature() }
		) {
			$0.avCaptureDeviceClient.requestAccess = { true }
		}
		
		await store.send(\.view.cameraButtonTapped)
		
		userSettings.authorizedVideoStatus = .authorized
		await store.send(\.view.cameraButtonTapped)
		
		userSettings.authorizedVideoStatus = .notDetermined
		await store.send(\.view.cameraButtonTapped)
		
		await store.receive(\.requestAccessResponse, true) {
			$0.userSettings.authorizedVideoStatus = .authorized
		}
	}
	
	func testSnapshot() {
		withSnapshotTesting(record: .never, diffTool: "ksdiff") {
			@Shared(.userSettings) var userSettings: UserSettings = .defaultValue
			
			for language in Localizable.allCases {
				userSettings.language = language
				
				assertSnapshot(
					CameraView(
						store: Store(
							initialState: CameraFeature.State(),
							reducer: {}
						)
					)
				)
				
				userSettings.authorizedVideoStatus = .authorized
				
				assertSnapshot(
					CameraView(
						store: Store(
							initialState: CameraFeature.State(),
							reducer: {}
						)
					)
				)
				
				userSettings.authorizedVideoStatus = .denied
				
				assertSnapshot(
					CameraView(
						store: Store(
							initialState: CameraFeature.State(),
							reducer: {}
						)
					)
				)
				
				userSettings.authorizedVideoStatus = .notDetermined
			}
		}
	}
}
