import DesignSystem
import Foundation
import Models
import SwiftUI

enum SettingsRowType: Sendable {
  case about
  case agreements
  case appearance
  case camera(String)
  case export
  case language(Localizable)
  case microphone(String)
  case insert(LocalAuthenticationType)
  case menu(LocalAuthenticationType)
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
    case .export:
      "Settings.ExportPDF".localized
    case .microphone:
      "Settings.Microphone".localized
    case .camera:
      "Settings.Camera".localized
    case let .insert(localAuthenticationType), let .menu(localAuthenticationType):
      "Settings.Code".localized(with: [localAuthenticationType.rawValue])
    case .appearance:
      "Settings.Appearance".localized
    case .splash:
      "Settings.Splash".localized
    case .language:
      "Settings.Language".localized
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
    case .export:
        .adaptiveBlack
    case .microphone:
        .bluePure
    case .camera:
        .pink
    case .insert, .menu:
        .greenPure
    case .appearance:
        .orangePure
    case .splash:
        .redPure
    case .language:
        .brown
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
    case .export:
        .docRichtext
    case .microphone:
        .mic
    case .insert, .menu:
        .faceid
    case .appearance:
        .rectangleOnRectangle
    case .splash:
        .book
    case .language:
        .paperclipCircle
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
    case let .microphone(title), let .camera(title):
      Text(title)
        .foregroundColor(.adaptiveGray)
        .adaptiveFont(.latoRegular, size: 12)
        .minimumScaleFactor(0.01)
        .lineLimit(1)
    case .insert:
      Text("Settings.Off".localized)
        .foregroundColor(.adaptiveGray)
        .adaptiveFont(.latoRegular, size: 12)
    case .menu:
      Text("Settings.On".localized)
        .foregroundColor(.adaptiveGray)
        .adaptiveFont(.latoRegular, size: 12)
    case let .language(language):
      Text(language.localizable.localized)
        .foregroundColor(.adaptiveGray)
        .adaptiveFont(.latoRegular, size: 12)
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
