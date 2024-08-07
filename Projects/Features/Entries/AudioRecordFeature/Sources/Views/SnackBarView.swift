//
//  SnackBarView.swift
//  
//
//  Created by Albert Gil Escura on 28/8/21.
//

import SwiftUI

struct SnackBarView: View {
    private let message: String
    
    init(message: String) {
        self.message = message
    }
    
    var body: some View {
        Text(message)
            .foregroundColor(.adaptiveWhite)
            .padding(8)
            .background(Color.chambray.opacity(0.5))
            .cornerRadius(6)
    }
}
