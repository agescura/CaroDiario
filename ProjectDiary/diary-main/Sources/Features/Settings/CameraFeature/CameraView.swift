import SwiftUI
import ComposableArchitecture
import AVCaptureDeviceClient
import UIApplicationClient
import FeedbackGeneratorClient
import Localizables
import Styles
import Models
import SwiftUIHelper

public struct CameraView: View {
  let store: StoreOf<CameraFeature>
  
  public init(
    store: StoreOf<CameraFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
		WithPerceptionTracking {
      Form {
        Section(
          footer:
            Group {
							if self.store.cameraStatus != .denied {
                Text(self.store.cameraStatus.description)
              } else {
                Text(self.store.cameraStatus.description)
                + Text(" ") +
                Text("Settings.GoToSettings".localized)
                  .underline()
                  .foregroundColor(.blue)
              }
            }
            .onTapGesture {
							self.store.send(.goToSettings)
            }
        ) {
          HStack {
            Text(self.store.cameraStatus.rawValue.localized)
              .foregroundColor(.chambray)
              .adaptiveFont(.latoRegular, size: 10)
            Spacer()
            if self.store.cameraStatus == .notDetermined {
              Text(self.store.cameraStatus.permission)
                .foregroundColor(.adaptiveGray)
                .adaptiveFont(.latoRegular, size: 12)
              Image(.chevronRight)
                .foregroundColor(.adaptiveGray)
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
						self.store.send(.cameraButtonTapped)
          }
        }
      }
      .navigationBarTitle("Settings.Camera.Privacy".localized, displayMode: .inline)
    }
  }
}

extension AuthorizedVideoStatus {
  var description: String {
    switch self {
      
    case .notDetermined:
      return "notDetermined.description".localized
    case .denied:
      return "denied.description".localized
    case .authorized:
      return "authorized.description".localized
    case .restricted:
      return "restricted.description".localized
    }
  }
  
  var permission: String {
    switch self {
    case .notDetermined:
      return "Settings.GivePermission".localized
    default:
      return ""
    }
  }
}
