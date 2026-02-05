import DesignSystem
import Foundation
import SwiftUI

struct ExportRowView: View {
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: .docRichtext)
        .foregroundColor(.adaptiveBlack)
      Text("Settings.ExportPDF".localized)
        .foregroundColor(.chambray)
        .adaptiveFont(.latoRegular, size: 12)
      Spacer()
    }
  }
}
