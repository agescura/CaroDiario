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

public struct VerticalLabeledContentStyle: LabeledContentStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    VStack(alignment: .leading) {
      HStack {
        configuration.label
      }
      configuration.content
    }
  }
}

extension LabeledContentStyle where Self == VerticalLabeledContentStyle {
  public static var vertical: VerticalLabeledContentStyle { VerticalLabeledContentStyle() }
}

public struct HorizontalLabeledContentStyle: LabeledContentStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    HStack(alignment: .top) {
      VStack {
        configuration.label
      }
      configuration.content
    }
  }
}

extension LabeledContentStyle where Self == HorizontalLabeledContentStyle {
  public static var horizontal: HorizontalLabeledContentStyle { HorizontalLabeledContentStyle() }
}
