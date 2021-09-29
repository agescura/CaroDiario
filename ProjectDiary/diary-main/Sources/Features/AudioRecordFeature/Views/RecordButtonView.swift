//
//  RecordButtonView.swift
//  
//
//  Created by Albert Gil Escura on 28/8/21.
//

import SwiftUI

struct RecordButtonView: View {
    let isRecording: Bool
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: isRecording ? size * 0.1 : size / 2)
                .fill(Color.berryRed)
                .frame(width: isRecording ? size / 2 : size, height: isRecording ? size / 2 : size)
                .animation(.default)
            
            Circle()
                .stroke(Color.adaptiveGray, lineWidth: size * 0.04)
                .frame(width: size + size * 0.1, height: size + size * 0.1)
        }
        .onTapGesture {
            action()
        }
    }
}
