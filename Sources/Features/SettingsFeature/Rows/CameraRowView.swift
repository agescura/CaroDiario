import DesignSystem
import Foundation
import SwiftUI

struct CameraRowView: View {
  let title: String
  
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: .rectangleOnRectangle)
        .foregroundColor(.pink)
      Text("Settings.Camera".localized)
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
