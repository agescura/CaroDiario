import Foundation
import SwiftUI
import Views

struct SplashRowView: View {
    var body: some View {
        HStack(spacing: 16) {
            IconImageView(
                .book,
                foregroundColor: .berryRed
            )
            Text("Settings.Splash".localized)
                .foregroundColor(.chambray)
                .adaptiveFont(.latoRegular, size: 12)
        }
    }
}
