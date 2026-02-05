import SwiftUI

extension View {
  public func foregroundColor(_ color: Color) -> some View {
    self.foregroundStyle(color)
  }
}
