import Foundation
import ComposableArchitecture
import Models
import AVAudioSessionClient
import FeedbackGeneratorClient
import UIApplicationClient

public struct Microphone: Reducer {
  public init() {}
  
  public struct State: Equatable {
    public var microphoneStatus: AudioRecordPermission
    
    public init(
      microphoneStatus: AudioRecordPermission
    ) {
      self.microphoneStatus = microphoneStatus
    }
  }
  
  public enum Action: Equatable {
    case microphoneButtonTapped
    case requestAccessResponse(Bool)
    case goToSettings
  }
  
  @Dependency(\.applicationClient) private var applicationClient
  @Dependency(\.feedbackGeneratorClient) private var feedbackGeneratorClient
  @Dependency(\.avAudioSessionClient) private var avAudioSessionClient
  
  public var body: some ReducerOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action> {
    switch action {
    case .microphoneButtonTapped:
      switch state.microphoneStatus {
      case .notDetermined:
        return .run { send in
          await self.feedbackGeneratorClient.selectionChanged()
          do {
            await send(.requestAccessResponse(try await self.avAudioSessionClient.requestRecordPermission()))
          } catch {
            await send(.requestAccessResponse(false))
          }
        }
        
      default:
        break
      }
      return .none
      
    case let .requestAccessResponse(authorized):
      state.microphoneStatus = authorized ? .authorized : .denied
      return .none
      
    case .goToSettings:
      guard state.microphoneStatus != .notDetermined else { return .none }
      return .run { _ in await self.applicationClient.openSettings() }
    }
  }
}
