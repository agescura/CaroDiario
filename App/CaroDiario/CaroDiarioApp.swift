import SwiftUI
import SettingsFeature
import AppFeature
import ComposableArchitecture
import SQLiteDataClient

@main
struct CaroDiarioApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Environment(\.scenePhase) var scenePhase
  
  init() {
    prepareDependencies {
      $0.defaultDatabase = try! appDatabase()
    }
  }

  var body: some Scene {
    WindowGroup {
      if !_XCTIsTesting {
        AppView(store: self.appDelegate.store)
          .onOpenURL(perform: self.appDelegate.process)
          .onChange(of: self.scenePhase) { self.appDelegate.update(state: $1) }
      }
    }
  }
}
