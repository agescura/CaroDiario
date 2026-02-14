import SwiftUI

public struct SecondaryButtonStyle: ButtonStyle {
  @Environment(\.customButtonIsLoading) var customButtonIsLoading
  @Environment(\.isEnabled) var isEnabled

  public func makeBody(configuration: Configuration) -> some View {
    HStack {
      Spacer()
      configuration.label
      Spacer()
    }
    
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color.adaptiveWhite)
    .foregroundColor(isEnabled ? .chambray : .adaptiveGray)
    .cornerRadius(16)
    .opacity(isEnabled ? 1.0 : 0.5)
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(isEnabled ? Color.chambray : .adaptiveGray, lineWidth: 1)
        .opacity(isEnabled ? 1.0 : 0.5)
    )
    .shadow(radius: configuration.isPressed ? 0 : 5, x:0, y: configuration.isPressed ? 0 : 3)
    .scaleEffect(configuration.isPressed ? 0.95 : 1)
    .animation(.spring(), value: configuration.isPressed)
    .disabled(!isEnabled)
    .opacity(isEnabled && !customButtonIsLoading ? 1.0 : 0.5)
  }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
  public static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}

#Preview {
  VStack {
    Button("default") {}
      .buttonStyle(.secondary)
    Button("disable false") {}
      .buttonStyle(.secondary)
      .disabled(false)
    Button("disable true") {}
      .buttonStyle(.secondary)
      .disabled(true)
    Button("loading false") {}
      .buttonStyle(.secondary)
      .customButton(isLoading: false)
    Button("loading true") {}
      .buttonStyle(.secondary)
      .customButton(isLoading: true)
    Button("disable true loading false") {}
      .buttonStyle(.secondary)
      .customButton(isLoading: false)
      .disabled(true)
    Button("disable true loading true") {}
      .buttonStyle(.secondary)
      .customButton(isLoading: true)
      .disabled(true)
    Button("disable true loading false") {}
      .buttonStyle(.secondary)
      .customButton(isLoading: false)
      .disabled(true)
    Button("disable false loading false") {}
      .buttonStyle(.secondary)
      .customButton(isLoading: false)
      .disabled(false)
  }
  .padding()
}

//public struct SecondaryButtonView<Label>: View where Label : View {
//    let label: Label
//    let disabled: Bool
//    let inFlight: Bool
//    let action: () -> Void
//    
//    public init(
//        @ViewBuilder label: () -> Label,
//        disabled: Bool = false,
//        inFlight: Bool = false,
//        action: @escaping () -> Void
//    ) {
//        self.label = label()
//        self.disabled = disabled
//        self.inFlight = inFlight
//        self.action = action
//    }
//    
//    public var body: some View {
//        Button(
//            action: action
//        ) {
//            ZStack {
//                if inFlight {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .chambray))
//                        
//                } else {
//                    label
//                }
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.adaptiveWhite)
//            .foregroundColor(disabled ? .adaptiveGray : .chambray)
//            .cornerRadius(16)
//            .opacity(disabled ? 0.5 : 1.0)
//            .overlay(
//                    RoundedRectangle(cornerRadius: 16)
//                        .stroke(disabled ? Color.adaptiveGray : .chambray, lineWidth: 1)
//                        .opacity(disabled ? 0.5 : 1.0)
//                )
//        }
//        .disabled(disabled || inFlight)
//    }
//}
