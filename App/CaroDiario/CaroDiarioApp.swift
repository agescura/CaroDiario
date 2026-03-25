import SwiftUI
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
        AppView(store: appDelegate.store)
          .onOpenURL(perform: appDelegate.process)
          .onChange(of: scenePhase) { appDelegate.update(state: $1) }
      }
    }
  }
}
