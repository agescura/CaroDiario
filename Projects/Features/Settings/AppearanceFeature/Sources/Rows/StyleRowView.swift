import Foundation
import SwiftUI
import Views

struct StyleRowView: View {
  let title: String
  
  var body: some View {
    HStack(spacing: 16) {
      IconImageView(
        .app,
        foregroundColor: .orange
      )
      Text("Settings.Style".localized)
        .foregroundColor(.chambray)
        .adaptiveFont(.latoRegular, size: 12)
      Spacer()
      Text(self.title)
        .foregroundColor(.adaptiveGray)
        .adaptiveFont(.latoRegular, size: 12)
    }
  }
}
