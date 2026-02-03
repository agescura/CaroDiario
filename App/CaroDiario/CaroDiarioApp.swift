import SwiftUI
import AboutFeature
import ComposableArchitecture
import DesignSystem

@main
struct CaroDiarioApp: App {
  init() {
    registerFonts()
  }
  var body: some Scene {
    WindowGroup {
      AboutView(
        store: Store(
          initialState: AboutFeature.State(),
          reducer: { AboutFeature() }
        )
      )
    }
  }
}
