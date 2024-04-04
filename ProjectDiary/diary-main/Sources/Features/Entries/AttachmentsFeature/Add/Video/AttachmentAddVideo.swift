import SwiftUI
import ComposableArchitecture
import FileClient
import Views
import Models
import Localizables
import UIApplicationClient
import AVKit

public struct AttachmentAddVideo: Reducer {
	public init() {}
	
	public struct State: Equatable {
		@PresentationState public var alert: AlertState<Action.Alert>?
		public var entryVideo: EntryVideo
		public var presentVideoPlayer: Bool = false
		
		public init(
			entryVideo: EntryVideo
		) {
			self.entryVideo = entryVideo
		}
	}
	
	public enum Action: Equatable {
		case alert(PresentationAction<Alert>)
		case presentVideoPlayer(Bool)
		case videoAlertButtonTapped
		
		public enum Alert: Equatable {
			case remove
		}
	}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .alert(.presented(.remove)):
					state.presentVideoPlayer = false
					return .none
				case .alert:
					return .none
					
				case let .presentVideoPlayer(value):
					state.presentVideoPlayer = value
					return .none
					
				case .videoAlertButtonTapped:
					state.alert = AlertState {
						TextState("Video.Remove.Description".localized)
					} actions: {
						ButtonState(role: .cancel, label: { TextState("Cancel".localized) })
						ButtonState(role: .destructive, action: .remove, label: { TextState("Video.Remove.Title".localized) })
					}
					return .none
			}
		}
	}
}

struct AttachmentAddVideoView: View {
	let store: StoreOf<AttachmentAddVideo>
	
	var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			ZStack {
				ImageView(url: viewStore.entryVideo.thumbnail)
					.frame(width: 52, height: 52)
				Image(.playFill)
					.foregroundColor(.adaptiveWhite)
					.frame(width: 8, height: 8)
			}
			.onTapGesture {
				viewStore.send(.presentVideoPlayer(true))
			}
			.fullScreenCover(
				isPresented: viewStore.binding(
					get: \.presentVideoPlayer,
					send: AttachmentAddVideo.Action.presentVideoPlayer
				)
			) {
				ZStack {
					Color.black
						.edgesIgnoringSafeArea(.all)
					
					VStack {
						HStack(spacing: 8) {
							Spacer()
							Button(action: {
								viewStore.send(.videoAlertButtonTapped)
							}) {
								Image(.trash)
									.frame(width: 48, height: 48)
									.foregroundColor(.chambray)
							}
							
							Button(action: {
								viewStore.send(.presentVideoPlayer(false))
							}) {
								Image(.xmark)
									.frame(width: 48, height: 48)
									.foregroundColor(.chambray)
							}
						}
						
						VideoPlayer(player: AVPlayer(url: viewStore.entryVideo.url))
							.edgesIgnoringSafeArea([.bottom, .horizontal])
					}
					.alert(
						store: self.store.scope(state: \.$alert, action: { .alert($0) })
					)
				}
			}
		}
	}
}

