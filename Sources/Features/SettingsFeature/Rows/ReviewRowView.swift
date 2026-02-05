import DesignSystem
import Foundation
import SwiftUI

struct ReviewRowView: View {
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: .numberSquare)
        .foregroundColor(.yellowPure)
      Text("Settings.ReviewAppStore".localized)
        .foregroundColor(.chambray)
        .adaptiveFont(.latoRegular, size: 12)
      Spacer()
      Image(systemName: .chevronRight)
        .foregroundColor(.adaptiveGray)
    }
  }
}
