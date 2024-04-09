import SwiftUI
import ComposableArchitecture
import UserDefaultsClient
import Styles

public struct AppDelegateState: Equatable {
  public init() {}
}

@CasePathable
public enum AppDelegateAction: Equatable {
  case didFinishLaunching
}
