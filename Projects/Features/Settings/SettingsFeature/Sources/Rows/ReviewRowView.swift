//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import Foundation
import SwiftUI
import Views

struct ReviewRowView: View {
    var body: some View {
        HStack(spacing: 16) {
            IconImageView(
                .numberSquare,
                foregroundColor: .yellow
            )
            Text("Settings.ReviewAppStore".localized)
                .foregroundColor(.chambray)
                .adaptiveFont(.latoRegular, size: 12)
            Spacer()
            Image(.chevronRight)
                .foregroundColor(.adaptiveGray)
        }
    }
}
