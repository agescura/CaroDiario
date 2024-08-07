import Foundation
import SwiftUI
import Views

struct ThemeRowView: View {
  let iconName: String
  let title: String
  
  var body: some View {
    HStack(spacing: 16) {
      IconImageView(
        systemName: self.iconName,
        foregroundColor: .berryRed
      )
      Text("Settings.Theme".localized)
        .foregroundColor(.chambray)
        .adaptiveFont(.latoRegular, size: 12)
      Spacer()
      Text(self.title)
        .foregroundColor(.adaptiveGray)
        .adaptiveFont(.latoRegular, size: 12)
    }
  }
}
