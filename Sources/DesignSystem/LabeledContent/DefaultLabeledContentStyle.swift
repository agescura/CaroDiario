import SwiftUI

public struct DefaultLabeledContentStyle: LabeledContentStyle {
  public func makeBody(configuration: Configuration) -> some View {
    LabeledContent {
      configuration.content
        .foregroundColor(.adaptiveGray)
    } label: {
      configuration.label
        .foregroundColor(.chambray)
    }
    .adaptiveFont(.latoRegular, size: 12)
  }
}

extension LabeledContentStyle where Self == DefaultLabeledContentStyle {
  public static var `default`: DefaultLabeledContentStyle { DefaultLabeledContentStyle() }
}

#Preview {
  Form {
    LabeledContent("Label") {
      Text("Content")
    }
    .labeledContentStyle(.default)
  }
}
