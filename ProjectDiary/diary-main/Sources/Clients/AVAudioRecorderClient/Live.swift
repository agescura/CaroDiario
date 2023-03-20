import ComposableArchitecture
import AVFoundation
import Combine
import Dependencies

extension AVAudioRecorderClient: DependencyKey {
  public static var liveValue: AVAudioRecorderClient { .live }
}

extension AVAudioRecorderClient {
  public static var live: Self = {
    Self(
      create: { id in
        .run { subscriber in
          let recorder = AVAudioRecorder()
          var delegate = AudioRecorderDelegate(subscriber)
          recorder.delegate = delegate
          
          dependencies[id] = Dependencies(
            delegate: delegate,
            recorder: recorder,
            subscriber: subscriber
          )
          
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
      
      record: { id, url in
        let recordSettings: [String: Any] = [
          AVFormatIDKey: Int(kAudioFormatLinearPCM),
          AVSampleRateKey: 44100.0,
          AVNumberOfChannelsKey: 1,
          AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        return .fireAndForget {
          do {
            let newRecorder = try AVAudioRecorder(url: url, settings: recordSettings)
            newRecorder.delegate = dependencies[id]?.delegate
            dependencies[id]?.recorder = newRecorder
            dependencies[id]?.recorder.record()
          } catch {}
        }
      },
      
      stop: { id in
          .fireAndForget {
            guard dependencies[id]?.recorder != nil else { return }
            dependencies[id]?.recorder.stop()
            dependencies[id]?.recorder = nil
          }
      }
    )
  }()
}

struct Dependencies {
  let delegate: AudioRecorderDelegate
  var recorder: AVAudioRecorder!
  let subscriber: EffectTask<AVAudioRecorderClient.Action>.Subscriber
}

var dependencies: [AnyHashable: Dependencies] = [:]

class AudioRecorderDelegate: NSObject, AVAudioRecorderDelegate {
  let subscriber: EffectTask<AVAudioRecorderClient.Action>.Subscriber
  
  init(_ subscriber: EffectTask<AVAudioRecorderClient.Action>.Subscriber) {
    self.subscriber = subscriber
    
  }
  func audioRecorderEncodeErrorDidOccur(_: AVAudioRecorder, error: Error?) {
    subscriber.send(.encodeErrorDidOccur(AVAudioRecorderClient.Error(error)))
  }
  
  func audioRecorderDidFinishRecording(_: AVAudioRecorder, successfully flag: Bool) {
    subscriber.send(.didFinishRecording(successfully: flag))
  }
}
