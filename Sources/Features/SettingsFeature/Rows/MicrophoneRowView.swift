import DesignSystem
import Foundation
import SwiftUI

struct MicrophoneRowView: View {
  let title: String
  
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: .mic)
        .foregroundColor(.bluePure)
      Text("Settings.Microphone".localized)
        .foregroundColor(.chambray)
        .adaptiveFont(.latoRegular, size: 12)
      Spacer()
      Text(self.title)
        .foregroundColor(.adaptiveGray)
        .adaptiveFont(.latoRegular, size: 12)
        .minimumScaleFactor(0.01)
        .lineLimit(1)
    }
  }
}
