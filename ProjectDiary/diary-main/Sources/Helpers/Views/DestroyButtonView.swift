import SwiftUI

public struct DestroyButtonView: View {
    let text: String
    let action: () -> Void
    let disabled: Bool
    let inFlight: Bool
    
    public init(
        text: String = "",
        action: @escaping () -> Void,
        disabled: Bool = false,
        inFlight: Bool = false
    ) {
        self.text = text
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
                        .progressViewStyle(CircularProgressViewStyle(tint: .berryRed))
                        
                } else {
                    Text(text)
                        
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.adaptiveWhite)
            .foregroundColor(.berryRed)
            .cornerRadius(16)
            .opacity(disabled ? 0.5 : 1.0)
            .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.berryRed, lineWidth: 1)
                )
        }
        .disabled(disabled)
    }
}
