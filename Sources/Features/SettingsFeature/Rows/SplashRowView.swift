import DesignSystem
import Foundation
import SwiftUI

struct SplashRowView: View {
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: .book)
        .foregroundColor(.redPure)
      Text("Settings.Splash".localized)
        .foregroundColor(.chambray)
        .adaptiveFont(.latoRegular, size: 12)
    }
  }
}
