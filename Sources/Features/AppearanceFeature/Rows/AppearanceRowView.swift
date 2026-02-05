import Foundation
import DesignSystem
import Localizables
import SwiftUI

enum AppearanceType {
  case theme(iconName: String, title: String)
  case layout(title: String)
  case style(title: String)
  case icon(title: String)
  
  var contentTitle: String {
    switch self {
    case let .theme(iconName: _, title: title):
      title
    case let .layout(title: title), let .style(title: title), let .icon(title: title):
      title
    }
  }
  
  var labelTitle: String {
    switch self {
    case .icon:
      "Settings.Icon".localized
    case .layout:
      "Settings.Layout".localized
    case .style:
      "Settings.Style".localized
    case .theme:
      "Settings.Theme".localized
    }
  }
  
  var iconName: SystemImage {
    switch self {
    case let .theme(iconName, _):
      SystemImage(rawValue: iconName) ?? .system
    case .layout:
      .seal
    case .style:
      .app
    case .icon:
      .appFill
    }
  }
  
  var color: Color {
    switch self {
    case .icon:
        .yellowPure
    case .layout:
        .bluePure
    case .style:
        .orangePure
    case .theme:
        .redPure
    }
  }
}

struct AppearanceRowView: View {
  let type: AppearanceType
  
  init(type: AppearanceType) {
    self.type = type
  }
  
  var body: some View {
    LabeledContent {
      Text(type.contentTitle)
    } label: {
      HStack(spacing: .s16) {
        Image(systemName: type.iconName)
          .foregroundColor(type.color)
        Text(type.labelTitle)
      }
    }
    .labeledContentStyle(.default)
  }
}

#Preview {
  List {
    AppearanceRowView(
      type: .style(title: "Rectangle")
    )
    AppearanceRowView(
      type: .layout(title: "Horizontal")
    )
    AppearanceRowView(
      type: .theme(iconName: "star", title: "System")
    )
    AppearanceRowView(
      type: .icon(title: "Light")
    )
  }
}
