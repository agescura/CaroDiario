import ComposableArchitecture
import Foundation
import Models
import SwiftUI

public struct AttachmentRowAudioDetailFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		let entryAudio: EntryAudio
		@PresentationState public var alert: AlertState<Action.Alert>?
		var isPlaying: Bool = false
		var playerDuration: Double = 0
		var isPlayerDragging: Bool = false
		var isDragging = false
		var playerProgress: CGFloat = 0
		var playerProgressTime: Double = 0
		
		public init(
			entryAudio: EntryAudio
		) {
			self.entryAudio = entryAudio
		}
	}
	
	public enum Action: Equatable {
		case alertButtonTapped
		case alert(PresentationAction<Alert>)
		case audioPlayerDidFinish(TaskResult<Bool>)
		case audioButtonTapped
		case playButtonTapped
		case playerProgressAddTimer
		case playerProgressResponse(Double)
		
		public enum Alert {
			case removeButtonTapped
		}
	}
	
	@Dependency(\.fileClient) private var fileClient
	@Dependency(\.avAudioPlayerClient) private var avAudioPlayerClient
	@Dependency(\.mainQueue) private var mainQueue
	private enum CancelID {
		case timer
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .alertButtonTapped:
					state.alert = .remove
					return .none
					
				case .alert:
					return .none
					
				case .audioPlayerDidFinish(.success(true)):
					state.playerProgress = 0
					state.isPlaying = false
					state.playerProgressTime = 0
					return .cancel(id: CancelID.timer)
				case .audioPlayerDidFinish:
					return .cancel(id: CancelID.timer)
					
				case .audioButtonTapped:
					return .none
				
				case .playerProgressAddTimer:
					if state.isDragging { return .none }
					state.playerProgressTime += 1
					return .run { send in
						let playerDuration = await self.avAudioPlayerClient.currentTime()
						await send(.playerProgressResponse(playerDuration), animation: .default)
					}
						
				case let .playerProgressResponse(playerDuration):
					let screen = UIScreen.main.bounds.width - 30
					let value = state.playerProgressTime / playerDuration
					state.playerProgress = screen * CGFloat(value)
					return .none
					
				case .playButtonTapped:
					if state.isPlaying {
						state.isPlaying = false
						state.playerProgressTime = 0
						state.playerProgress = 0
						state.playerProgressTime = 0
						return .merge(
							.run { _ in try await self.avAudioPlayerClient.stop() },
							.cancel(id: CancelID.timer)
						)
					}
					state.isPlaying = true

					return .run { [url = state.entryAudio.url] send in
						async let startPlaying: Void = send(
							.audioPlayerDidFinish(
								TaskResult { try await self.avAudioPlayerClient.play(url) }
							)
						)
						for await _ in self.mainQueue.timer(interval: .seconds(1)) {
							await send(.playerProgressAddTimer)
						}
						await startPlaying
					}
					.cancellable(id: CancelID.timer)
			}
		}
	}
}

extension AlertState where Action == AttachmentRowAudioDetailFeature.Action.Alert {
	static var remove: Self {
		AlertState {
			TextState("Audio.Remove.Description".localized)
		} actions: {
			ButtonState.destructive(.init("Audio.Remove.Title".localized), action: .send(.removeButtonTapped))
		}
	}
}
