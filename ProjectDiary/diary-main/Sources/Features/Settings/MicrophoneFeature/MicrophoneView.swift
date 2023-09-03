import ComposableArchitecture
import SwiftUI
import Localizables
import Styles
import Models
import SwiftUIHelper

public struct MicrophoneView: View {
  private let store: StoreOf<Microphone>
  
  public init(
    store: StoreOf<Microphone>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Form {
        Section(
          footer:
            Group {
              if viewStore.recordPermission != .denied {
                Text(viewStore.recordPermission.description)
              } else {
                Text(viewStore.recordPermission.description)
                + Text(" ") +
                Text("Settings.GoToSettings".localized)
                  .underline()
                  .foregroundColor(.blue)
              }
            }
            .onTapGesture {
              viewStore.send(.goToSettings)
            }
        ) {
          HStack {
            Text(viewStore.recordPermission.title.localized)
              .foregroundColor(.chambray)
              .adaptiveFont(.latoRegular, size: 10)
            Spacer()
            if viewStore.recordPermission == .undetermined {
              Text("Settings.GivePermission".localized)
                .foregroundColor(.adaptiveGray)
                .adaptiveFont(.latoRegular, size: 8)
              Image(.chevronRight)
                .foregroundColor(.adaptiveGray)
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            viewStore.send(.microphoneButtonTapped)
          }
        }
      }
      .navigationBarTitle("Settings.Camera.Privacy".localized, displayMode: .inline)
    }
  }
}

extension RecordPermission {
  public var description: String {
    switch self {
    case .granted:
      return "microphone.authorized.description".localized
    case .denied:
      return "microphone.denied.description".localized
    case .undetermined:
      return "microphone.notDetermined.description".localized
    }
  }
}

extension RecordPermission {
  public var title: String {
    switch self {
    case .granted:
      return "microphone.authorized".localized
    case .denied:
      return "microphone.denied".localized
    case .undetermined:
      return "microphone.notDetermined".localized
    }
  }
}
