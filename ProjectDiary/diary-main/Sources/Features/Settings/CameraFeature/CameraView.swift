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
							if self.store.userSettings.authorizedVideoStatus != .denied {
                Text(self.store.userSettings.authorizedVideoStatus.description)
              } else {
                Text(self.store.userSettings.authorizedVideoStatus.description)
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
            Text(self.store.userSettings.authorizedVideoStatus.rawValue.localized)
              .foregroundColor(.chambray)
              .adaptiveFont(.latoRegular, size: 10)
            Spacer()
            if self.store.userSettings.authorizedVideoStatus == .notDetermined {
              Text(self.store.userSettings.authorizedVideoStatus.permission)
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
			.task { await self.store.send(.task).finish() }
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

#Preview {
	CameraView(
		store: Store(
			initialState: CameraFeature.State(),
			reducer: { CameraFeature() }
		)
	)
}
