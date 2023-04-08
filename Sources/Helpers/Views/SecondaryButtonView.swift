//
//  SecondaryButtonView.swift
//
//  Created by Albert Gil Escura on 12/7/21.
//

import SwiftUI

public struct SecondaryButtonView<Label>: View where Label : View {
    let label: Label
    let disabled: Bool
    let inFlight: Bool
    let action: () -> Void
    
    public init(
        @ViewBuilder label: () -> Label,
        disabled: Bool = false,
        inFlight: Bool = false,
        action: @escaping () -> Void
    ) {
        self.label = label()
        self.disabled = disabled
        self.inFlight = inFlight
        self.action = action
    }
    
    public var body: some View {
        Button(
            action: action
        ) {
            ZStack {
                if inFlight {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .chambray))
                        
                } else {
                    label
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.adaptiveWhite)
            .foregroundColor(disabled ? .adaptiveGray : .chambray)
            .cornerRadius(16)
            .opacity(disabled ? 0.5 : 1.0)
            .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(disabled ? Color.adaptiveGray : .chambray, lineWidth: 1)
                        .opacity(disabled ? 0.5 : 1.0)
                )
        }
        .disabled(disabled || inFlight)
    }
}
