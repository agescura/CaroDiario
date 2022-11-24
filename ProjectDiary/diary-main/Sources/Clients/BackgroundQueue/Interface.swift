import Foundation
import Dependencies
import ComposableArchitecture

extension DependencyValues {
  public var backgroundQueue: AnySchedulerOf<DispatchQueue> {
    get { self[BackgroundQueueKey.self] }
    set { self[BackgroundQueueKey.self] = newValue }
  }
  
  private enum BackgroundQueueKey: DependencyKey {
    static let liveValue = DispatchQueue(label: "background-queue").eraseToAnyScheduler()
    static let testValue = AnySchedulerOf<DispatchQueue>
      .unimplemented(#"@Dependency(\.backgroundQueue)"#)
  }
}
