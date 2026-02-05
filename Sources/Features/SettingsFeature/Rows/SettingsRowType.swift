import DesignSystem
import Foundation
import SwiftUI

enum SettingsRowType: Sendable {
  case about
  case agreements
  case appearance
  case camera
  case export
  case language
  case microphone
  case passcode
  case review
  case splash
  
  var title: String {
    switch self {
    case .about:
      "Settings.About".localized
    case .agreements:
      "Settings.Agreements".localized
    case .review:
      "Settings.ReviewAppStore".localized
    default:
      "NO TEXT"
    }
  }
  
  var iconColor: Color {
    switch self {
    case .about:
        .purplePure
    case .agreements:
        .purplePure
    case .review:
        .yellowPure
    default:
        .black
    }
  }
  
  var icon: SystemImage {
    switch self {
    case .about:
        .message
    case .agreements:
        .heartFill
    case .review:
        .numberSquare
    default:
        .seal
    }
  }
  
  @MainActor
  @ViewBuilder
  var content: some View {
    switch self {
    case .review:
      Image(systemName: .chevronRight)
        .foregroundColor(.adaptiveGray)
    default:
      EmptyView()
    }
  }
}

struct SettingsRowView: View {
  let type: SettingsRowType
  
  init(type: SettingsRowType) {
    self.type = type
  }
  
  var body: some View {
    LabeledContent {
      type.content
    } label: {
      HStack(spacing: .s16) {
        Image(systemName: type.icon)
          .foregroundColor(type.iconColor)
        Text(type.title)
      }
    }
    .labeledContentStyle(.default)
  }
}
