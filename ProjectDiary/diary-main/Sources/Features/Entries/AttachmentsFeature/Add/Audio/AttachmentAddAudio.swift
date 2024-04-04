import SwiftUI
import ComposableArchitecture
import FileClient
import Views
import Models
import AVAudioPlayerClient

public struct AttachmentAddAudio: Reducer {
	public init() {}
	
	public struct State: Equatable {
		public var entryAudio: EntryAudio
		public var presentAudioFullScreen: Bool = false
		
//		public var removeFullScreenAlert: AlertState<AttachmentAddAudio.Action>?
//		public var removeAlert: AlertState<AttachmentAddAudio.Action>?
		
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
		case audioPlayerDidFinish(TaskResult<Bool>)
		case audioButtonTapped
		case playerProgressAddTimer
		case playerProgressResponse(Double)
		case presentAudioFullScreen(Bool)
		
		case remove
		case removeFullScreenAlertButtonTapped
		case dismissRemoveFullScreen
		case cancelRemoveFullScreenAlert
		
		case playButtonTapped
	}
	
	@Dependency(\.fileClient) private var fileClient
	@Dependency(\.avAudioPlayerClient) private var avAudioPlayerClient
	@Dependency(\.mainQueue) private var mainQueue
	private enum CancelID {
		case timer
	}
	
	public var body: some ReducerOf<Self> {
		Reduce(self.core)
	}
	
	private func core(
		state: inout State,
		action: Action
	) -> Effect<Action> {
		switch action {
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
				return .send(.playerProgressResponse(state.playerProgressTime), animation: .default)
				
			case let .playerProgressResponse(progress):
				state.playerProgressTime = progress
				
				let screen = UIScreen.main.bounds.width - 30
				let value = progress / state.playerDuration
				state.playerProgress = screen * CGFloat(value)
				return .none
				
			case let .presentAudioFullScreen(value):
				state.presentAudioFullScreen = value
				return .none
				
			case .removeFullScreenAlertButtonTapped:
//				state.removeFullScreenAlert = .init(
//					title: .init("Audio.Remove.Description".localized),
//					primaryButton: .cancel(.init("Cancel".localized)),
//					secondaryButton: .destructive(.init("Audio.Remove.Title".localized), action: .send(.remove))
//				)
				return .none
				
			case .dismissRemoveFullScreen:
//				state.removeFullScreenAlert = nil
				state.presentAudioFullScreen = false
				return .none
				
			case .remove:
				state.presentAudioFullScreen = false
//				state.removeFullScreenAlert = nil
				return .none
				
			case .cancelRemoveFullScreenAlert:
//				state.removeFullScreenAlert = nil
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

struct AttachmentAddAudioView: View {
	private let store: StoreOf<AttachmentAddAudio>
	
	init(
		store: StoreOf<AttachmentAddAudio>
	) {
		self.store = store
	}
	
	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			Rectangle()
				.fill(Color.adaptiveGray)
				.frame(width: 52, height: 52)
				.overlay(
					Image(systemName: "waveform")
						.foregroundColor(.adaptiveWhite)
						.frame(width: 8, height: 8)
				)
				.onTapGesture {
					viewStore.send(.audioButtonTapped)
				}
				.fullScreenCover(
					isPresented: viewStore.binding(
						get: \.presentAudioFullScreen,
						send: AttachmentAddAudio.Action.presentAudioFullScreen
					)
				) {
					VStack {
						HStack(spacing: 8) {
							Spacer()
							
							Button(
								action: {
									viewStore.send(.removeFullScreenAlertButtonTapped)
								}
							) {
								Image(systemName: "trash")
									.frame(width: 48, height: 48)
									.foregroundColor(.chambray)
							}
							
							Button(
								action: {
									viewStore.send(.presentAudioFullScreen(false))
								}
							) {
								Image(systemName: "xmark")
									.frame(width: 48, height: 48)
									.foregroundColor(.chambray)
							}
						}
						
						Spacer()
						
						Group {
							ZStack(alignment: .leading) {
								Capsule()
									.fill(Color.black.opacity(0.08))
									.frame(height: 8)
								Capsule()
									.fill(Color.red)
									.frame(width: viewStore.playerProgress, height: 8)
									.animation(nil, value: UUID())
							}
							
							HStack {
								Text(viewStore.playerProgressTime.formatter)
									.adaptiveFont(.latoRegular, size: 10)
									.foregroundColor(.chambray)
								
								Spacer()
								
								Text(viewStore.playerDuration.formatter)
									.adaptiveFont(.latoRegular, size: 10)
									.foregroundColor(.chambray)
							}
							
							HStack {
								Color.clear
									.frame(width: 24, height: 24)
								
								Spacer()
								
								Button {
									viewStore.send(.playButtonTapped)
								} label: {
									Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
										.resizable()
										.aspectRatio(contentMode: .fill)
										.frame(width: 32, height: 32)
										.foregroundColor(.chambray)
								}
								
								Spacer()
							}
							Spacer()
						}
						.padding()
						.animation(.default, value: UUID())
					}
//					.alert(
//						store.scope(state: \.removeFullScreenAlert),
//						dismiss: .cancelRemoveFullScreenAlert
//					)
				}
		}
	}
}
