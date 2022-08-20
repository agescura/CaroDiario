//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import Foundation
import SwiftUI
import Views

struct SplashRowView: View {
    var body: some View {
        HStack(spacing: 16) {
            IconImageView(
                systemName: "book",
                foregroundColor: .berryRed
            )
            Text("Settings.Splash".localized)
                .foregroundColor(.chambray)
                .adaptiveFont(.latoRegular, size: 12)
        }
    }
}
