import SwiftUI

extension HStack {
  public init(
    alignment: VerticalAlignment = .center,
    spacing: Spacing,
    @ViewBuilder content: () -> Content
  ) {
    self.init(
      alignment: alignment,
      spacing: spacing.rawValue,
      content: content
    )
  }
}
