//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import Foundation
import SwiftUI
import Views

struct ExportRowView: View {
    var body: some View {
        HStack(spacing: 16) {
            IconImageView(
                systemName: "doc.richtext",
                foregroundColor: .adaptiveBlack)
            Text("Settings.ExportPDF".localized)
                .foregroundColor(.chambray)
                .adaptiveFont(.latoRegular, size: 12)
            Spacer()
        }
    }
}
