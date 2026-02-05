import DesignSystem
import Foundation
import SwiftUI

struct AgreementsRowView: View {
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: .heartFill)
        .foregroundColor(.purplePure)
      Text("Settings.Agreements".localized)
        .foregroundColor(.chambray)
        .adaptiveFont(.latoRegular, size: 12)
      Spacer()
    }
  }
}
