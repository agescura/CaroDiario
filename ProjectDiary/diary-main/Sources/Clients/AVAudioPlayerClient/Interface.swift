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

    var create: (AnyHashable, URL) -> EffectTask<Action> = { _, _ in .fireAndForget {} }
    var destroy: (AnyHashable) -> EffectTask<Never> = { _ in .fireAndForget {} }
    var duration: (AnyHashable) -> EffectTask<Double> = { _ in .fireAndForget {} }
    var play: (AnyHashable) -> EffectTask<Never> = { _ in .fireAndForget {} }
    var pause: (AnyHashable) -> EffectTask<Never> = { _ in .fireAndForget {} }
    var stop: (AnyHashable) -> EffectTask<Never> = { _ in .fireAndForget {} }
    var isPlaying: (AnyHashable) -> EffectTask<Bool> = { _ in .fireAndForget {}}
    var currentTime: (AnyHashable) -> EffectTask<Double> =  { _ in .fireAndForget {} }
    var setCurrentTime: (AnyHashable, Double) -> EffectTask<Never> = { _, _ in .fireAndForget {} }
    
    public init(
        create: @escaping (AnyHashable, URL) -> EffectTask<Action> = { _, _ in .fireAndForget {} },
        destroy: @escaping (AnyHashable) -> EffectTask<Never> = { _ in .fireAndForget {} },
        duration: @escaping (AnyHashable) -> EffectTask<Double> = { _ in .fireAndForget {} },
        play: @escaping (AnyHashable) -> EffectTask<Never> = { _ in .fireAndForget {} },
        pause: @escaping (AnyHashable) -> EffectTask<Never> = { _ in .fireAndForget {} },
        stop: @escaping (AnyHashable) -> EffectTask<Never> = { _ in .fireAndForget {} },
        isPlaying: @escaping (AnyHashable) -> EffectTask<Bool> = { _ in .fireAndForget {}},
        currentTime: @escaping (AnyHashable) -> EffectTask<Double> =  { _ in .fireAndForget {} },
        setCurrentTime: @escaping (AnyHashable, Double) -> EffectTask<Never> = { _, _ in .fireAndForget {} }
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

    public func create(id: AnyHashable, url: URL) -> EffectTask<Action> {
        create(id, url)
    }

    public func destroy(id: AnyHashable) -> EffectTask<Never> {
        destroy(id)
    }
    
    public func duration(id: AnyHashable) -> EffectTask<Double> {
        duration(id)
    }

    public func play(id: AnyHashable) -> EffectTask<Never> {
        play(id)
    }
    
    public func pause(id: AnyHashable) -> EffectTask<Never> {
        pause(id)
    }

    public func stop(id: AnyHashable) -> EffectTask<Never> {
        stop(id)
    }
    
    public func isPlaying(id: AnyHashable) -> EffectTask<Bool> {
        isPlaying(id)
    }
    
    public func currentTime(id: AnyHashable) -> EffectTask<Double> {
        currentTime(id)
    }
    
    public func setCurrentTime(id: AnyHashable, currentTime: Double) -> EffectTask<Never> {
        setCurrentTime(id, currentTime)
    }
}
