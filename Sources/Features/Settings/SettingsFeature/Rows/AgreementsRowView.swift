//
//  File.swift
//  
//
//  Created by Albert Gil Escura on 20/8/22.
//

import Foundation
import SwiftUI
import Views

struct AgreementsRowView: View {
    var body: some View {
        HStack(spacing: 16) {
            IconImageView(
                .heartFill,
                foregroundColor: .purple
            )
            Text("Settings.Agreements".localized)
                .foregroundColor(.chambray)
                .adaptiveFont(.latoRegular, size: 12)
            Spacer()
        }
    }
}
