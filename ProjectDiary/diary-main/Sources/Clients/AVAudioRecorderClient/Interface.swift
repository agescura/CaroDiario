import ComposableArchitecture
import Foundation
import Dependencies

extension DependencyValues {
  public var avAudioRecorderClient: AVAudioRecorderClient {
    get { self[AVAudioRecorderClient.self] }
    set { self[AVAudioRecorderClient.self] = newValue }
  }
}

public struct AVAudioRecorderClient {
    public enum Action: Equatable {
        case encodeErrorDidOccur(Error?)
        case didFinishRecording(successfully: Bool)
    }

    public struct Error: Swift.Error, Equatable {
        public let error: NSError?

        public  init(_ error: Swift.Error?) {
            self.error = error as NSError?
        }
    }

    public init(
        create: @escaping (AnyHashable) -> EffectTask<Action>,
        destroy: @escaping (AnyHashable) -> EffectTask<Never>,
        record: @escaping (AnyHashable, URL) -> EffectTask<Never>,
        stop: @escaping (AnyHashable) -> EffectTask<Never>
    ) {
        self.create = create
        self.destroy = destroy
        self.record = record
        self.stop = stop
    }

    var create: (AnyHashable) -> EffectTask<Action>
    var destroy: (AnyHashable) -> EffectTask<Never>
    var record: (AnyHashable, URL) -> EffectTask<Never>
    var stop: (AnyHashable) -> EffectTask<Never>

    public func create(id: AnyHashable) -> EffectTask<Action> {
        create(id)
      }

    public func destroy(id: AnyHashable) -> EffectTask<Never> {
        destroy(id)
    }

    public func record(id: AnyHashable, url: URL) -> EffectTask<Never> {
        record(id, url)
    }

    public func stop(id: AnyHashable) -> EffectTask<Never> {
        stop(id)
    }
}

