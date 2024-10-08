import Foundation
import SwiftUI
import Views

struct IconAppRowView: View {
  let title: String
  
  var body: some View {
    HStack(spacing: 16) {
      IconImageView(
        .appFill,
        foregroundColor: .yellow
      )
      Text("Settings.Icon".localized)
        .foregroundColor(.chambray)
        .adaptiveFont(.latoRegular, size: 12)
      Spacer()
      Text(self.title)
        .foregroundColor(.adaptiveGray)
        .adaptiveFont(.latoRegular, size: 12)
    }
  }
}
