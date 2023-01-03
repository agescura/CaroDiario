import Foundation
import SwiftUI
import Views

struct PasscodeRowView: View {
  let title: String
  let status: String
  
  var body: some View {
    HStack(spacing: 16) {
      IconImageView(
        .faceid,
        foregroundColor: .green
      )
      Text(self.title)
        .foregroundColor(.chambray)
        .adaptiveFont(.latoRegular, size: 12)
      Spacer()
      Text(self.status)
        .foregroundColor(.adaptiveGray)
        .adaptiveFont(.latoRegular, size: 12)
      Image(.chevronRight)
        .foregroundColor(.adaptiveGray)
      
    }
  }
}
