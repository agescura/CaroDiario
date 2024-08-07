import SwiftUI
import ComposableArchitecture
import FileClient
import Views
import Models
import Localizables
import UIApplicationClient
import AVKit

@Reducer
public struct AttachmentAddVideo {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		@Presents public var alert: AlertState<Action.Alert>?
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
		
		@CasePathable
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
	@Bindable var store: StoreOf<AttachmentAddVideo>
	
	var body: some View {
		ZStack {
			ImageView(url: self.store.entryVideo.thumbnail)
				.frame(width: 52, height: 52)
			Image(.playFill)
				.foregroundColor(.adaptiveWhite)
				.frame(width: 8, height: 8)
		}
		.onTapGesture {
			self.store.send(.presentVideoPlayer(true))
		}
		.fullScreenCover(
			isPresented: self.$store.presentVideoPlayer.sending(\.presentVideoPlayer)
		) {
			ZStack {
				Color.black
					.edgesIgnoringSafeArea(.all)
				
				VStack {
					HStack(spacing: 8) {
						Spacer()
						Button(action: {
							self.store.send(.videoAlertButtonTapped)
						}) {
							Image(.trash)
								.frame(width: 48, height: 48)
								.foregroundColor(.chambray)
						}
						
						Button(action: {
							self.store.send(.presentVideoPlayer(false))
						}) {
							Image(.xmark)
								.frame(width: 48, height: 48)
								.foregroundColor(.chambray)
						}
					}
					
					VideoPlayer(player: AVPlayer(url: self.store.entryVideo.url))
						.edgesIgnoringSafeArea([.bottom, .horizontal])
				}
				.alert(
					store: self.store.scope(state: \.$alert, action: \.alert)
				)
			}
		}
	}
}

