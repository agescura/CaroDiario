import AudioRecordFeature
import ComposableArchitecture
import SwiftUI

@main
struct AudioRecordFeaturePreviewApp: App {
    var body: some Scene {
        WindowGroup {
            AudioRecordView(
                store: Store(
						initialState: AudioRecordFeature.State(),
						reducer: { AudioRecordFeature()._printChanges() }
                )
            )
        }
    }
}
