import SwiftUI
import ComposableArchitecture
import AVAudioPlayerClient
import AVAudioSessionClient
import AVAudioRecorderClient
import AudioRecordFeature
import UIApplicationClient
import FileClient

@main
struct AudioRecordFeaturePreviewApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationView {
        NavigationLink("Audio Recorder") {
          AudioRecordView(
            store: .init(
              initialState: .init(),
              reducer: AudioRecord().debug()
            )
          )
        }
      }
    }
  }
}
