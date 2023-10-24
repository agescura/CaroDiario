import Foundation
import SwiftUI
import Views

struct MicrophoneRowView: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            IconImageView(
                .mic,
                foregroundColor: .blue
            )
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
