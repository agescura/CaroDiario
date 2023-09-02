@preconcurrency import AVFoundation
import Combine
import ComposableArchitecture
import Dependencies

extension AVAudioPlayerClient: DependencyKey {
	public static var liveValue: AVAudioPlayerClient { .live }
}

extension AVAudioPlayerClient {
	public static var live: Self = {
		let audioPlayer = AudioPlayer()
		
		return Self(
			currentTime: { await audioPlayer.currentTime() },
			play: { try await audioPlayer.start(url: $0) },
			stop: { await audioPlayer.stop() }
		)
	}()
}

private actor AudioPlayer {
	var delegate: Delegate?
	var player: AVAudioPlayer?
	
	func currentTime() async -> TimeInterval {
		self.delegate!.player.duration
	}
	
	func stop() {
		self.delegate?.player.stop()
		try? AVAudioSession.sharedInstance().setActive(false)
	}
	
	func start(url: URL) async throws -> Bool {
		self.stop()
		
		let stream = AsyncThrowingStream<Bool, Error> { continuation in
			do {
				self.delegate = try Delegate(
					url: url,
					didFinishPlaying: { successful in
						continuation.yield(successful)
						continuation.finish()
					},
					decodeErrorDidOccur: { error in
						continuation.finish(throwing: error)
					}
				)
				self.delegate?.player.play()
				continuation.onTermination = { [delegate = delegate] _ in
					delegate?.player.stop()
				}
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

private final class Delegate: NSObject, AVAudioPlayerDelegate, Sendable {
	let didFinishPlaying: @Sendable (Bool) -> Void
	let decodeErrorDidOccur: @Sendable (Error?) -> Void
	let player: AVAudioPlayer
	
	init(
		url: URL,
		didFinishPlaying: @escaping @Sendable (Bool) -> Void,
		decodeErrorDidOccur: @escaping @Sendable (Error?) -> Void
	) throws {
		self.didFinishPlaying = didFinishPlaying
		self.decodeErrorDidOccur = decodeErrorDidOccur
		self.player = try AVAudioPlayer(contentsOf: url)
		super.init()
		self.player.delegate = self
	}
	
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		self.didFinishPlaying(flag)
	}
	
	func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
		self.decodeErrorDidOccur(error)
	}
}
