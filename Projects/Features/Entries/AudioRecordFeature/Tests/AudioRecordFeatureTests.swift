import XCTest
import ComposableArchitecture
@testable import AudioRecordFeature
import AVAudioSessionClient

@MainActor
class AudioRecordFeatureTests: XCTestCase {
  func testCreateAndDestroyAudioDependencies() {
    let store = TestStore(
      initialState: .init(),
      reducer: AudioRecord()
    )
    
    store.send(.onAppear)
  }
  
  func testRequestPermissionsResponseDenied() async {
    let store = TestStore(
      initialState: .init(),
      reducer: AudioRecord()
    )
    
    await store.send(.requestMicrophonePermissionButtonTapped)
    await store.receive(.requestMicrophonePermissionResponse(false)) {
      $0.audioRecordPermission = .denied
    }
    
    await store.send(.permissionButtonTapped)
  }
  
  func testRequestPermissionsResponseAuthorized() async {
    let store = TestStore(
      initialState: .init(),
        reducer: AudioRecord()
    )
    
    await store.send(.requestMicrophonePermissionButtonTapped)
    await store.receive(.requestMicrophonePermissionResponse(true)) {
      $0.audioRecordPermission = .authorized
    }
  }
  
  func testRecordAudioAndPlay() async {
    let store = TestStore(
      initialState: .init(),
        reducer: AudioRecord()
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
