//
//  PrimaryButtonView.swift
//
//  Created by Albert Gil Escura on 27/6/21.
//

import SwiftUI

public struct PrimaryButtonView<Label> : View where Label : View {
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
                } else {
                    label
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.chambray)
            .foregroundColor(.adaptiveWhite)
            .cornerRadius(16)
            .opacity(disabled ? 0.5 : 1.0)
        }
        .disabled(disabled)
    }
}
