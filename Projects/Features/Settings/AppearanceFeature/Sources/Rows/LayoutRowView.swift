import Foundation
import SwiftUI
import Views

struct LayoutRowView: View {
  let title: String
  
  var body: some View {
    HStack(spacing: 16) {
      IconImageView(
        .seal,
        foregroundColor: .blue
      )
      Text("Settings.Layout".localized)
        .foregroundColor(.chambray)
        .adaptiveFont(.latoRegular, size: 12)
      Spacer()
      Text(self.title)
        .foregroundColor(.adaptiveGray)
        .adaptiveFont(.latoRegular, size: 12)
    }
  }
}
