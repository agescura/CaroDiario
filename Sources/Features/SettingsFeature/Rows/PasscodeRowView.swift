import DesignSystem
import Foundation
import SwiftUI

struct PasscodeRowView: View {
  let title: String
  let status: String
  
  var body: some View {
    HStack(spacing: 16) {
      Image(systemName: .faceid)
        .foregroundColor(.greenPure)
      Text(self.title)
        .foregroundColor(.chambray)
        .adaptiveFont(.latoRegular, size: 12)
      Spacer()
      Text(self.status)
        .foregroundColor(.adaptiveGray)
        .adaptiveFont(.latoRegular, size: 12)
      Image(systemName: .chevronRight)
        .foregroundColor(.adaptiveGray)
      
    }
  }
}
