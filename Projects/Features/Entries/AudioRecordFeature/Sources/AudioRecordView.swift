import ComposableArchitecture
import SwiftUI
import Views
import Styles
import Localizables
import SwiftHelper
import Models
import AVAudioRecorderClient

extension RecordPermission {
	var description: String {
		switch self {
			case .granted:
				return "AudioRecord.Authorized".localized
			case .denied:
				return "AudioRecord.Denied".localized
			case .undetermined:
				fallthrough
			@unknown default:
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
						
					case .undetermined:
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
						
					case .granted:
						
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
								
								Button(action: {}, label: {})
									.frame(width: 24, height: 24)
									.opacity(0)
								
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
								
								Button {
									viewStore.send(.removeAudioRecord)
								} label: {
									Image(systemName: "trash")
										.resizable()
										.aspectRatio(contentMode: .fill)
										.frame(width: 20, height: 20)
										.foregroundColor(.chambray)
								}
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
				store: self.store.scope(
					state: \.$alert,
					action: \.alert
				)
			)
		}
	}
}
