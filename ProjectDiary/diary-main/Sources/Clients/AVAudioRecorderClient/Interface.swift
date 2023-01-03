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
        create: @escaping (AnyHashable) -> Effect<Action, Never>,
        destroy: @escaping (AnyHashable) -> Effect<Never, Never>,
        record: @escaping (AnyHashable, URL) -> Effect<Never, Never>,
        stop: @escaping (AnyHashable) -> Effect<Never, Never>
    ) {
        self.create = create
        self.destroy = destroy
        self.record = record
        self.stop = stop
    }

    var create: (AnyHashable) -> Effect<Action, Never>
    var destroy: (AnyHashable) -> Effect<Never, Never>
    var record: (AnyHashable, URL) -> Effect<Never, Never>
    var stop: (AnyHashable) -> Effect<Never, Never>

    public func create(id: AnyHashable) -> Effect<Action, Never> {
        create(id)
      }

    public func destroy(id: AnyHashable) -> Effect<Never, Never> {
        destroy(id)
    }

    public func record(id: AnyHashable, url: URL) -> Effect<Never, Never> {
        record(id, url)
    }

    public func stop(id: AnyHashable) -> Effect<Never, Never> {
        stop(id)
    }
}

