import ComposableArchitecture
import AVFoundation
import Combine
import Dependencies

extension RecordPermission {
	public init(_ permission: AVAudioSession.RecordPermission) {
		switch permission {
			case .denied:
				self = .denied
			case .granted:
				self = .granted
			case .undetermined:
				fallthrough
			@unknown default:
				self = .undetermined
		}
	}
}

extension AVAudioRecorderClient: DependencyKey {
	public static var liveValue: AVAudioRecorderClient { .live }
}

extension AVAudioRecorderClient {
	public static var live: Self = {
		let audioRecorder = AudioRecorder()
		
		return Self(
			currentTime: { await audioRecorder.currentTime },
			recordPermission: { AudioRecorder.recordPermission() },
			requestRecordPermission: { await AudioRecorder.requestPermission() },
			startRecording: { url in try await audioRecorder.start(url: url) },
			stopRecording: { await audioRecorder.stop() }
		)
	}()
}

private actor AudioRecorder {
	var delegate: Delegate?
	var recorder: AVAudioRecorder?
	
	var currentTime: TimeInterval? {
		guard
			let recorder = self.recorder,
			recorder.isRecording
		else { return nil }
		return recorder.currentTime
	}
	
	static func recordPermission() -> RecordPermission {
		RecordPermission(AVAudioSession.sharedInstance().recordPermission)
	}
	
	static func requestPermission() async -> RecordPermission {
		await withUnsafeContinuation { continuation in
			AVAudioSession.sharedInstance().requestRecordPermission { granted in
				continuation.resume(returning: granted ? .granted : .denied)
			}
		}
	}
	
	func stop() {
		self.recorder?.stop()
		try? AVAudioSession.sharedInstance().setActive(false)
	}
	
	func start(url: URL) async throws -> Bool {
		self.stop()
		
		let stream = AsyncThrowingStream<Bool, Error> { continuation in
			do {
				self.delegate = Delegate(
					didFinishRecording: { flag in
						continuation.yield(flag)
						continuation.finish()
						try? AVAudioSession.sharedInstance().setActive(false)
					},
					encodeErrorDidOccur: { error in
						continuation.finish(throwing: error)
						try? AVAudioSession.sharedInstance().setActive(false)
					}
				)
				let recorder = try AVAudioRecorder(
					url: url,
					settings: [
						AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
						AVSampleRateKey: 44100,
						AVNumberOfChannelsKey: 1,
						AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
					])
				self.recorder = recorder
				recorder.delegate = self.delegate
				
				continuation.onTermination = { [recorder = UncheckedSendable(recorder)] _ in
					recorder.wrappedValue.stop()
				}
				
				try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
				try AVAudioSession.sharedInstance().setActive(true)
				self.recorder?.record()
			} catch {
				continuation.finish(throwing: error)
			}
		}
		
		for try await didFinish in stream {
			return didFinish
		}
		throw CancellationError()
	}
}

private final class Delegate: NSObject, AVAudioRecorderDelegate, Sendable {
	let didFinishRecording: @Sendable (Bool) -> Void
	let encodeErrorDidOccur: @Sendable (Error?) -> Void
	
	init(
		didFinishRecording: @escaping @Sendable (Bool) -> Void,
		encodeErrorDidOccur: @escaping @Sendable (Error?) -> Void
	) {
		self.didFinishRecording = didFinishRecording
		self.encodeErrorDidOccur = encodeErrorDidOccur
	}
	
	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		self.didFinishRecording(flag)
	}
	
	func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
		self.encodeErrorDidOccur(error)
	}
}
