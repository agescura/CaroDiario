import SwiftUI
import ComposableArchitecture
import EntriesFeature

@main
struct EntriesFeaturePreviewApp: App {
  var body: some Scene {
    WindowGroup {
      EntriesView(
        store: .init(
          initialState: .init(entries: []),
          reducer: Entries()
        )
      )
    }
  }
}
