import ComposableArchitecture
import SwiftUI
import Views
import Styles
import Localizables
import SwiftHelper
import Models

extension AudioRecordPermission {
	var description: String {
		switch self {
			case .authorized:
				return "AudioRecord.Authorized".localized
			case .denied:
				return "AudioRecord.Denied".localized
			case .notDetermined:
				return "AudioRecord.NotDetermined".localized
		}
	}
}

public struct AudioRecordView: View {
	private let store: StoreOf<AudioRecordFeature>
	
	public init(
		store: StoreOf<AudioRecordFeature>
	) {
		self.store = store
	}
	
	@State var rounded = false
	
	public var body: some View {
		WithViewStore(self.store, observe: { $0 }) { viewStore in
			VStack(spacing: 16) {
				Spacer()
				
				switch viewStore.audioRecordPermission {
						
					case .notDetermined:
						Text(viewStore.audioRecordPermission.description)
							.multilineTextAlignment(.center)
							.foregroundColor(.chambray)
							.adaptiveFont(.latoRegular, size: 14)
						Spacer()
						PrimaryButtonView(
							label: { Text("AudioRecord.AllowMicrophone".localized) },
							action: { viewStore.send(.requestMicrophonePermissionButtonTapped) }
						)
						
					case .denied:
						Text(viewStore.audioRecordPermission.description)
							.multilineTextAlignment(.center)
							.foregroundColor(.chambray)
							.adaptiveFont(.latoRegular, size: 14)
						Spacer()
						PrimaryButtonView(
							label: { Text("AudioRecord.GoToSettings".localized) },
							action: { viewStore.send(.goToSettings) }
						)
						
					case .authorized:
						
						Group {
							ZStack(alignment: .leading) {
								Capsule()
									.fill(Color.black.opacity(0.08))
									.frame(height: 8)
								Capsule()
									.fill(Color.red)
									.frame(width: viewStore.playerProgress, height: 8)
									.animation(nil, value: UUID())
									.gesture(
										DragGesture()
											.onChanged { value in
												viewStore.send(.dragOnChanged(value.location))
											}
											.onEnded { value in
												viewStore.send(.dragOnEnded(value.location))
											}
									)
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
								
								Button(action: {}, label: {})
									.frame(width: 24, height: 24)
									.opacity(0)
								
								Spacer()
								
								HStack(spacing: 42) {
									Button(action: {
										viewStore.send(.playerGoBackward)
									}, label: {
										Image(systemName: "gobackward.15")
											.resizable()
											.aspectRatio(contentMode: .fill)
											.frame(width: 24, height: 24)
											.foregroundColor(.chambray)
									})
									
									
									Button(action: {
										viewStore.send(.playButtonTapped)
									}, label: {
										Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
											.resizable()
											.aspectRatio(contentMode: .fill)
											.frame(width: 32, height: 32)
											.foregroundColor(.chambray)
									})
									
									Button(action: {
										viewStore.send(.playerGoForward)
									}, label: {
										Image(systemName: "goforward.15")
											.resizable()
											.aspectRatio(contentMode: .fill)
											.frame(width: 24, height: 24)
											.foregroundColor(.chambray)
									})
								}
								
								Spacer()
								
								Button(action: {
									viewStore.send(.removeAudioRecord)
								}, label: {
									Image(systemName: "trash")
										.resizable()
										.aspectRatio(contentMode: .fill)
										.frame(width: 20, height: 20)
										.foregroundColor(.chambray)
								})
							}
							
							Spacer()
						}
						.opacity(viewStore.hasAudioRecorded ? 1.0 : 0.0)
						.animation(.default, value: UUID())
						
						Text(viewStore.audioRecordDuration.formatter)
							.adaptiveFont(.latoBold, size: 20)
							.foregroundColor(.adaptiveBlack)
						
						RecordButtonView(
							isRecording: viewStore.isRecording,
							size: 100,
							action: {
								viewStore.send(.recordButtonTapped)
							}
						)
						
						Text("AudioRecord.StartRecording".localized)
							.multilineTextAlignment(.center)
							.adaptiveFont(.latoRegular, size: 10)
							.foregroundColor(.adaptiveGray)
						
						Spacer()
						
						PrimaryButtonView(
							label: { Text("AudioRecord.Add".localized) },
							disabled: !viewStore.hasAudioRecorded,
							inFlight: false,
							action: {
								viewStore.send(.addAudio)
							}
						)
				}
			}
			.padding()
			.onAppear {
				viewStore.send(.onAppear)
			}
			.alert(
				store.scope(state: \.dismissAlert),
				dismiss: .dismissCancelAlert
			)
			.alert(
				store.scope(state: \.recordAlert),
				dismiss: .recordCancelAlert
			)
		}
	}
}
