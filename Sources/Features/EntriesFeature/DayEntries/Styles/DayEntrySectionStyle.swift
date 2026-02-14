import Models
import SwiftUI

extension View {
  func dayEntrySection(styleType: StyleType) -> some View {
    environment(\.dayEntrySectionStyle, styleType)
  }
  func dayEntrySection(isExpanded: Bool) -> some View {
    environment(\.dayEntrySectionIsExpanded, isExpanded)
  }
}

private struct DayEntrySectionStyle: EnvironmentKey {
  nonisolated(unsafe) static var defaultValue: StyleType = .rectangle
}

extension EnvironmentValues {
  var dayEntrySectionStyle: StyleType {
    get { self[DayEntrySectionStyle.self] }
    set { self[DayEntrySectionStyle.self] = newValue }
  }
}
