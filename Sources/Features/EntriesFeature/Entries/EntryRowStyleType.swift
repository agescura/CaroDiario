import SwiftUI
import Models

extension View {
  func entryRow(styleType: StyleType) -> some View {
    environment(\.entryRowStyle, styleType)
  }
}

private struct EntryRowStyle: EnvironmentKey {
  nonisolated(unsafe) static var defaultValue: StyleType = .rectangle
}

extension EnvironmentValues {
  var entryRowStyle: StyleType {
    get { self[EntryRowStyle.self] }
    set { self[EntryRowStyle.self] = newValue }
  }
}
