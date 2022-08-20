//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import Foundation
import SwiftUI
import Views

struct CameraRowView: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            IconImageView(
                systemName: "camera",
                foregroundColor: .pink
            )
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
