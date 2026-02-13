import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
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
    .background(Color.chambray)
    .foregroundColor(.adaptiveWhite)
    .cornerRadius(16)
    .shadow(radius: configuration.isPressed ? 0 : 5, x:0, y: configuration.isPressed ? 0 : 3)
    .scaleEffect(configuration.isPressed ? 0.95 : 1)
    .animation(.spring(), value: configuration.isPressed)
    .disabled(!isEnabled)
    .opacity(isEnabled && !customButtonIsLoading ? 1.0 : 0.5)
  }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
  public static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

#Preview {
  VStack {
    Button("default") {}
      .buttonStyle(.primary)
    Button("disable false") {}
      .buttonStyle(.primary)
      .disabled(false)
    Button("disable true") {}
      .buttonStyle(.primary)
      .disabled(true)
    Button("loading false") {}
      .buttonStyle(.primary)
      .customButton(isLoading: false)
    Button("loading true") {}
      .buttonStyle(.primary)
      .customButton(isLoading: true)
    Button("disable true loading false") {}
      .buttonStyle(.primary)
      .customButton(isLoading: false)
      .disabled(true)
    Button("disable true loading true") {}
      .buttonStyle(.primary)
      .customButton(isLoading: true)
      .disabled(true)
    Button("disable true loading false") {}
      .buttonStyle(.primary)
      .customButton(isLoading: false)
      .disabled(true)
    Button("disable false loading false") {}
      .buttonStyle(.primary)
      .customButton(isLoading: false)
      .disabled(false)
  }
  .padding()
}

extension View {
  func customButton(isLoading: Bool) -> some View {
    environment(\.customButtonIsLoading, isLoading)
  }
}

private struct CustomButtonIsLoadingStyle: EnvironmentKey {
  nonisolated(unsafe) static var defaultValue: Bool = false
}

extension EnvironmentValues {
  var customButtonIsLoading: Bool {
    get { self[CustomButtonIsLoadingStyle.self] }
    set { self[CustomButtonIsLoadingStyle.self] = newValue }
  }
}
