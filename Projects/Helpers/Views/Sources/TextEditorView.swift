//
//  TextEditorView.swift
//
//  Created by Albert Gil Escura on 27/6/21.
//

import SwiftUI
import Styles

public struct TextEditorView: View {
    let placeholder: String
    @Binding var text: String
    
    public init(
        placeholder: String,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self._text = text
    }
    
    public var body: some View {
        ZStack {
            TextEditor(text: $text)
                .adaptiveFont(.latoRegular, size: 12)
                .foregroundColor(.adaptiveGray)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.adaptiveGray, lineWidth: 1)
                )
            
            if text.isEmpty {
                Text(placeholder)
                    .adaptiveFont(.latoRegular, size: 10)
                    .foregroundColor(.adaptiveGray.opacity(0.5))
                    .padding(24)
            }
        }
    }
}
