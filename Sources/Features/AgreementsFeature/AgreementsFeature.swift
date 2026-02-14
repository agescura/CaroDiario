import ApplicationClient
import ComposableArchitecture
import Foundation

public enum AgreementType: Sendable {
  case composableArchitecture
  case pointfree
  case raywenderlich
  
  public var url: URL {
    switch self {
    case .composableArchitecture:
      URL(string: "https://github.com/pointfreeco/swift-composable-architecture")!
    case .pointfree:
      URL(string: "https://www.pointfree.co/")!
    case .raywenderlich:
      URL(string: "https://www.raywenderlich.com/")!
    }
  }
  
  public var title: String {
    switch self {
    case .composableArchitecture:
      "The Composable Architecture"
    case .pointfree:
      "pointfree.co"
    case .raywenderlich:
      "raywenderlich.com"
    }
  }
}

@Reducer
public struct AgreementsFeature {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public init() {}
  }
  
  public enum Action: Equatable {
    case open(AgreementType)
  }
  
  @Dependency(\.applicationClient.open) private var open
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .open(type):
        return .run { [open] _ in await open(type.url, [:]) }
      }
    }
  }
}
