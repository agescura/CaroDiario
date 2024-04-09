import SwiftUI
import ComposableArchitecture
import AppFeature

@main
struct ProjectDiaryApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Environment(\.scenePhase) var scenePhase
  
  var body: some Scene {
    WindowGroup {
      AppView(store: self.appDelegate.store)
        .onOpenURL(perform: self.appDelegate.process(url:))
        .onChange(
          of: self.scenePhase,
          perform: self.appDelegate.update(state:)
        )
    }
  }
}
