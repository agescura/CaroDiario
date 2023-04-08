import SwiftUI
import ComposableArchitecture
import AddEntryFeature
import Styles

@main
struct AddEntryFeaturePreviewApp: App {
  
  init() {
    registerFonts()
  }
  
  var body: some Scene {
    WindowGroup {
      AddEntryView(
        store: .init(
          initialState: .init(type: .add, entry: .init(id: .init(), date: .init(), startDay: .init(), text: .init(id: .init(), message: "", lastUpdated: .init()))),
          reducer: AddEntry()
        )
      )
    }
  }
}
