@testable import AudioRecordFeature
import AVAudioSessionClient
import Combine
import ComposableArchitecture
import XCTest

@MainActor
class AudioRecordFeatureTests: XCTestCase {
	func testRequestRecordPermissionFailed() async {
		let openSettingsCalled = ActorIsolated(false)
		let store = TestStore(
			initialState: AudioRecordFeature.State(),
			reducer: AudioRecordFeature.init
		) {
			$0.avAudioRecorderClient.recordPermission = { .undetermined }
			$0.avAudioRecorderClient.requestRecordPermission = { .denied }
			$0.applicationClient.openSettings = { await openSettingsCalled.setValue(true) }
		}
		
		await store.send(.requestMicrophonePermissionButtonTapped)
		await store.receive(.requestMicrophonePermissionResponse(.denied)) {
			$0.audioRecordPermission = .denied
		}
		
		await store.send(.goToSettings)
		
		await openSettingsCalled.withValue { XCTAssertNoDifference($0, true) }
 	}
	
	func testRequestRecordGranted() async {
		let store = TestStore(
			initialState: AudioRecordFeature.State(),
			reducer: AudioRecordFeature.init
		) {
			$0.avAudioRecorderClient.recordPermission = { .undetermined }
			$0.avAudioRecorderClient.requestRecordPermission = { .granted }
		}
		
		await store.send(.requestMicrophonePermissionButtonTapped)
		await store.receive(.requestMicrophonePermissionResponse(.granted)) {
			$0.audioRecordPermission = .granted
		}
	}
	
	func testRecordAndPlay() async {
		let mainQueue = DispatchQueue.test
		let store = TestStore(
			initialState: AudioRecordFeature.State(),
			reducer: AudioRecordFeature.init
		) {
			$0.avAudioRecorderClient.recordPermission = { .granted }
			$0.uuid = .incrementing
			$0.mainQueue = mainQueue.eraseToAnyScheduler()
			$0.fileClient.path = { _ in URL(string: "wwww.google.es")! }
			$0.avAudioRecorderClient.startRecording = { _ in true }
		}
		
		await store.send(.recordButtonTapped)
		await store.receive(.record) {
			$0.isRecording = true
			$0.audioPath = URL(string: "wwww.google.es.caf")!
		}
		await store.receive(.audioRecorderDidFinish(.success(true))) {
			$0.isRecording = false
		}
	}
}
