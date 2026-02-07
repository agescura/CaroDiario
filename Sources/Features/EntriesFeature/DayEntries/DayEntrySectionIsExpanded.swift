import SwiftUI

private struct DayEntrySectionIsExpanded: EnvironmentKey {
  nonisolated(unsafe) static var defaultValue: Bool = false
}

extension EnvironmentValues {
  var dayEntrySectionIsExpanded: Bool {
    get { self[DayEntrySectionIsExpanded.self] }
    set { self[DayEntrySectionIsExpanded.self] = newValue }
  }
}
