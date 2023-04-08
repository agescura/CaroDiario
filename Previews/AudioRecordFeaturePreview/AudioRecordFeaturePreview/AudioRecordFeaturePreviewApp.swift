import SwiftUI
import ComposableArchitecture
import AudioRecordFeature

@main
struct AudioRecordFeaturePreviewApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationView {
        NavigationLink("Audio Recorder") {
          AudioRecordView(
            store: .init(
              initialState: .init(),
              reducer: AudioRecord()._printChanges()
            )
          )
        }
      }
    }
  }
}
