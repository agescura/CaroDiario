import DesignSystem
import Foundation
import SwiftUI

struct AppearanceRowView: View {
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: .rectangleOnRectangle)
        .foregroundColor(.orange)
      Text("Settings.Appearance".localized)
        .foregroundColor(.chambray)
        .adaptiveFont(.latoRegular, size: 12)
      Spacer()
    }
  }
}
