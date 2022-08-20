//
//  TerciaryButtonView.swift  
//
//  Created by Albert Gil Escura on 20/7/21.
//

import SwiftUI

public struct TerciaryButtonView<Label>: View where Label : View {
    let label: Label
    let action: () -> Void
    let disabled: Bool
    let inFlight: Bool
    
    public init(
        @ViewBuilder label: () -> Label,
        action: @escaping () -> Void,
        disabled: Bool = false,
        inFlight: Bool = false
    ) {
        self.label = label()
        self.action = action
        self.disabled = disabled
        self.inFlight = inFlight
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
            .background(Color.clear)
            .foregroundColor(.chambray)
            .cornerRadius(16)
            .opacity(disabled ? 0.5 : 1.0)
        }
        .disabled(disabled)
    }
}
