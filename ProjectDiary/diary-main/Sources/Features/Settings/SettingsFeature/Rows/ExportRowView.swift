import Foundation
import SwiftUI
import Views

struct ExportRowView: View {
    var body: some View {
        HStack(spacing: 16) {
            IconImageView(
                .docRichtext,
                foregroundColor: .adaptiveBlack)
            Text("Settings.ExportPDF".localized)
                .foregroundColor(.chambray)
                .adaptiveFont(.latoRegular, size: 12)
            Spacer()
        }
    }
}
