import SwiftUI
import ComposableArchitecture
import AVCaptureDeviceClient
import UIApplicationClient
import FeedbackGeneratorClient
import Localizables
import Styles
import Models
import SwiftUIHelper

public struct Camera: Reducer {
  public init() {}
  
  public struct State: Equatable {
    public var cameraStatus: AuthorizedVideoStatus
    
    public init(
      cameraStatus: AuthorizedVideoStatus
    ) {
      self.cameraStatus = cameraStatus
    }
  }
  
  public enum Action: Equatable {
    case cameraButtonTapped
    case requestAccessResponse(Bool)
    case goToSettings
  }
  
  @Dependency(\.applicationClient) private var applicationClient
  @Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
  @Dependency(\.avCaptureDeviceClient) private var avCaptureDeviceClient
  
  public var body: some ReducerOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action> {
    switch action {
    case .cameraButtonTapped:
      switch state.cameraStatus {
      case .notDetermined:
        return .run { send in
          await self.feedbackGeneratorClient.selectionChanged()
          await send(.requestAccessResponse(await self.avCaptureDeviceClient.requestAccess()))
        }
        
      default:
        break
      }
      return .none
      
    case let .requestAccessResponse(authorized):
      state.cameraStatus = authorized ? .authorized : .denied
      return .none
      
    case .goToSettings:
      guard state.cameraStatus != .notDetermined else { return .none }
      return .run { _ in await self.applicationClient.openSettings() }
    }
  }
}

public struct CameraView: View {
  let store: StoreOf<Camera>
  
  public init(
    store: StoreOf<Camera>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Form {
        Section(
          footer:
            Group {
              if viewStore.cameraStatus != .denied {
                Text(viewStore.cameraStatus.description)
              } else {
                Text(viewStore.cameraStatus.description)
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
            Text(viewStore.cameraStatus.rawValue.localized)
              .foregroundColor(.chambray)
              .adaptiveFont(.latoRegular, size: 10)
            Spacer()
            if viewStore.cameraStatus == .notDetermined {
              Text(viewStore.cameraStatus.permission)
                .foregroundColor(.adaptiveGray)
                .adaptiveFont(.latoRegular, size: 12)
              Image(.chevronRight)
                .foregroundColor(.adaptiveGray)
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            viewStore.send(.cameraButtonTapped)
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
