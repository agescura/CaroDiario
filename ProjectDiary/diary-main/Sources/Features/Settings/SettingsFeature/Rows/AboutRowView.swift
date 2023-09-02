import Foundation
import SwiftUI
import Views

struct AboutRowView: View {
    var body: some View {
        HStack(spacing: 16) {
            IconImageView(
                .message,
                foregroundColor: .purple
            )
            Text("Settings.About".localized)
                .foregroundColor(.chambray)
                .adaptiveFont(.latoRegular, size: 12)
            Spacer()
        }
    }
}
