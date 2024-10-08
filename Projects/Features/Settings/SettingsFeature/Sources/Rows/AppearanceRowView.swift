//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import Foundation
import SwiftUI
import Views

struct AppearanceRowView: View {
    var body: some View {
        HStack(spacing: 16) {
            IconImageView(
                .rectangleOnRectangle,
                foregroundColor: .orange
            )
            Text("Settings.Appearance".localized)
                .foregroundColor(.chambray)
                .adaptiveFont(.latoRegular, size: 12)
            Spacer()
        }
    }
}
