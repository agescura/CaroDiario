import AVFoundation
import Dependencies
import ComposableArchitecture

extension DependencyValues {
  public var avAudioPlayerClient: AVAudioPlayerClient {
    get { self[AVAudioPlayerClient.self] }
    set { self[AVAudioPlayerClient.self] = newValue }
  }
}

public struct AVAudioPlayerClient {
    public enum Action: Equatable {
        case decodeErrorDidOccur(Error?)
        case didFinishPlaying(successfully: Bool)
        case duration(Double)
    }

    public struct Error: Swift.Error, Equatable {
        public let error: NSError?

        public init(_ error: Swift.Error?) {
            self.error = error as NSError?
        }
    }

    var create: (AnyHashable, URL) -> Effect<Action> = { _, _ in .fireAndForget {} }
    var destroy: (AnyHashable) -> Effect<Never> = { _ in .fireAndForget {} }
    var duration: (AnyHashable) -> Effect<Double> = { _ in .fireAndForget {} }
    var play: (AnyHashable) -> Effect<Never> = { _ in .fireAndForget {} }
    var pause: (AnyHashable) -> Effect<Never> = { _ in .fireAndForget {} }
    var stop: (AnyHashable) -> Effect<Never> = { _ in .fireAndForget {} }
    var isPlaying: (AnyHashable) -> Effect<Bool> = { _ in .fireAndForget {}}
    var currentTime: (AnyHashable) -> Effect<Double> =  { _ in .fireAndForget {} }
    var setCurrentTime: (AnyHashable, Double) -> Effect<Never> = { _, _ in .fireAndForget {} }
    
    public init(
        create: @escaping (AnyHashable, URL) -> Effect<Action> = { _, _ in .fireAndForget {} },
        destroy: @escaping (AnyHashable) -> Effect<Never> = { _ in .fireAndForget {} },
        duration: @escaping (AnyHashable) -> Effect<Double> = { _ in .fireAndForget {} },
        play: @escaping (AnyHashable) -> Effect<Never> = { _ in .fireAndForget {} },
        pause: @escaping (AnyHashable) -> Effect<Never> = { _ in .fireAndForget {} },
        stop: @escaping (AnyHashable) -> Effect<Never> = { _ in .fireAndForget {} },
        isPlaying: @escaping (AnyHashable) -> Effect<Bool> = { _ in .fireAndForget {}},
        currentTime: @escaping (AnyHashable) -> Effect<Double> =  { _ in .fireAndForget {} },
        setCurrentTime: @escaping (AnyHashable, Double) -> Effect<Never> = { _, _ in .fireAndForget {} }
    ) {
        self.create = create
        self.destroy = destroy
        self.duration = duration
        self.play = play
        self.pause = pause
        self.stop = stop
        self.isPlaying = isPlaying
        self.currentTime = currentTime
        self.setCurrentTime = setCurrentTime
    }

    public func create(id: AnyHashable, url: URL) -> Effect<Action> {
        create(id, url)
    }

    public func destroy(id: AnyHashable) -> Effect<Never> {
        destroy(id)
    }
    
    public func duration(id: AnyHashable) -> Effect<Double> {
        duration(id)
    }

    public func play(id: AnyHashable) -> Effect<Never> {
        play(id)
    }
    
    public func pause(id: AnyHashable) -> Effect<Never> {
        pause(id)
    }

    public func stop(id: AnyHashable) -> Effect<Never> {
        stop(id)
    }
    
    public func isPlaying(id: AnyHashable) -> Effect<Bool> {
        isPlaying(id)
    }
    
    public func currentTime(id: AnyHashable) -> Effect<Double> {
        currentTime(id)
    }
    
    public func setCurrentTime(id: AnyHashable, currentTime: Double) -> Effect<Never> {
        setCurrentTime(id, currentTime)
    }
}
