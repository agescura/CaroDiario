import AVFoundation
import Combine
import ComposableArchitecture
import Dependencies

extension AVAudioPlayerClient: DependencyKey {
  public static var liveValue: AVAudioPlayerClient { .live }
}

extension AVAudioPlayerClient {
    public static var live: Self = {
        Self(
            create: { id, url in
                Effect.run { subscriber in
                    let delegate = AudioPlayerManagerDelegate(subscriber)

                    let player = try! AVAudioPlayer(contentsOf: url)
                    player.delegate = delegate
                    player.prepareToPlay()

                    dependencies[id] = Dependencies(
                        delegate: delegate,
                        player: player,
                        subscriber: subscriber,
                        queue: OperationQueue.main
                    )
                    
                    subscriber.send(.duration(player.duration))

                    return AnyCancellable {
                        dependencies[id] = nil
                    }
                }
            },
            
            destroy: { id in
                .fireAndForget {
                    dependencies[id]?.subscriber.send(completion: .finished)
                    dependencies[id] = nil
                }
            },
            
            duration: { id in
                guard let player = dependencies[id]?.player else { return .none }
                
                return Effect(value: player.duration)
            },
            
            play: { id in
                .fireAndForget {
                    dependencies[id]?.player.play()
                }
            },
            
            pause: { id in
                .fireAndForget { dependencies[id]?.player.pause() }
            },
            
            stop: { id in
                .fireAndForget { dependencies[id]?.player.stop() }
            },
            
            isPlaying: { id in
                guard let player = dependencies[id]?.player else { return Effect(value: false) }
                return Effect(value: player.isPlaying)
            },
            
            currentTime: { id in
                guard let player = dependencies[id]?.player else { return .none }
                return Effect(value: player.currentTime)
            },
            
            setCurrentTime: { id, currentTime in
                .fireAndForget { dependencies[id]?.player.currentTime = currentTime }
            }
        )
    }()
}

private struct Dependencies {
    var delegate: AVAudioPlayerDelegate
    var player: AVAudioPlayer
    let subscriber: EffectTask<AVAudioPlayerClient.Action>.Subscriber
    let queue: OperationQueue
}

private var dependencies: [AnyHashable: Dependencies] = [:]

private class AudioPlayerManagerDelegate: NSObject, AVAudioPlayerDelegate {
    let subscriber: EffectTask<AVAudioPlayerClient.Action>.Subscriber

    init(_ subscriber: EffectTask<AVAudioPlayerClient.Action>.Subscriber) {
        self.subscriber = subscriber
    }

    func audioPlayerDecodeErrorDidOccur(_: AVAudioPlayer, error: Error?) {
        subscriber.send(.decodeErrorDidOccur(AVAudioPlayerClient.Error(error)))
    }

    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully flag: Bool) {
        subscriber.send(.didFinishPlaying(successfully: flag))
    }
}
