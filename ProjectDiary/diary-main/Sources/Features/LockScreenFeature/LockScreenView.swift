import SwiftUI
import ComposableArchitecture
import Styles
import UserDefaultsClient
import Views
import LocalAuthenticationClient
import Localizables
import Models

public struct LockScreen: ReducerProtocol {
  public init() {}
  
  public struct State: Equatable {
    var code: String
    var codeToMatch: String = ""
    var wrongAttempts: Int = 0
    public var authenticationType: LocalAuthenticationType = .none
    public var buttons: [LockScreenNumber] = []
    
    public init(
      code: String,
      codeToMatch: String = ""
    ) {
      self.code = code
      self.codeToMatch = codeToMatch
    }
  }
  
  public enum Action: Equatable {
    case numberButtonTapped(LockScreenNumber)
    case matchedCode
    case failedCode
    case reset
    case onAppear
    case checkFaceId
    case determine(LocalAuthenticationType)
    case faceIdResponse(Bool)
  }
  
  @Dependency(\.userDefaultsClient) private var userDefaultsClient
  @Dependency(\.localAuthenticationClient) private var localAuthenticationClient
  @Dependency(\.mainQueue) private var mainQueue
  
  public var body: some ReducerProtocolOf<Self> {
    Reduce(self.core)
  }
  
  private func core(
    state: inout State,
    action: Action
  ) -> Effect<Action, Never> {
    switch action {
    case let .numberButtonTapped(item):
      if item == .biometric(.touchId) || item == .biometric(.faceId) {
        return Effect(value: .checkFaceId)
      }
      if let value = item.value {
        state.codeToMatch.append("\(value)")
      }
      if state.code == state.codeToMatch {
        return Effect(value: .matchedCode)
      } else if state.code.count == state.codeToMatch.count {
        return Effect(value: .failedCode)
      }
      return .none
      
    case .onAppear:
      return .merge(
        Effect(value: .checkFaceId),
        .run { send in
          await send(.determine(self.localAuthenticationClient.determineType()))
        }
      )
      
    case let .determine(type):
      state.authenticationType = type
      
      let leftButton: LockScreenNumber = type == .none || !self.userDefaultsClient.isFaceIDActivate ? .emptyLeft : .biometric(type)
      state.buttons = [
        .number(1),
        .number(2),
        .number(3),
        .number(4),
        .number(5),
        .number(6),
        .number(7),
        .number(8),
        .number(9),
        leftButton,
        .number(0),
        .emptyRight
      ]
      return .none
      
    case .checkFaceId:
      
      if self.userDefaultsClient.isFaceIDActivate {
        return .run { send in
          await send(.faceIdResponse(self.localAuthenticationClient.evaluate("JIJIJAJAJ")))
        }
      } else {
        return .none
      }
      
    case let .faceIdResponse(value):
      if value {
        return Effect(value: .matchedCode)
          .delay(for: 0.5, scheduler: self.mainQueue)
          .eraseToEffect()
      }
      return .none
      
    case .matchedCode:
      return .none
      
    case .failedCode:
      state.wrongAttempts = 4
      state.codeToMatch = ""
      return Effect(value: .reset)
        .delay(for: 0.5, scheduler: self.mainQueue)
        .eraseToEffect()
      
    case .reset:
      state.wrongAttempts = 0
      return .none
    }
  }
}

public struct LockScreenView: View {
  let store: StoreOf<LockScreen>
  private let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
  ]
  
  public init(
    store: StoreOf<LockScreen>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack(spacing: 16) {
        Spacer()
        Text("LockScreen.Title".localized)
        HStack {
          ForEach(0..<viewStore.code.count, id: \.self) { iterator in
            Image(systemName: viewStore.codeToMatch.count > iterator ? "circle.fill" : "circle")
          }
        }
        .modifier(ShakeGeometryEffect(animatableData: CGFloat(viewStore.wrongAttempts)))
        Spacer()
        LazyVGrid(columns: columns) {
          ForEach(viewStore.buttons) { item in
            Button(
              action: {
                viewStore.send(.numberButtonTapped(item), animation: .default)
              },
              label: {
                LockScreenButton(number: item)
              }
            )
          }
        }
        .padding(.horizontal)
        Spacer()
      }
      .onAppear {
        viewStore.send(.onAppear)
      }
    }
  }
}

public enum LockScreenNumber: Equatable, Identifiable {
  case number(Int)
  case emptyLeft
  case emptyRight
  case biometric(LocalAuthenticationType)
  
  public var id: String {
    switch self {
    case let .number(value):
      return "\(value)"
    case .emptyLeft:
      return "emptyLeft"
    case .emptyRight:
      return "emptyRight"
    case .biometric(.touchId):
      return "touchid"
    case .biometric(.faceId):
      return "faceid"
    case .biometric:
      return "none"
    }
  }
  
  public var value: Int? {
    switch self {
    case let .number(value):
      return value
    case .emptyLeft, .emptyRight, .biometric:
      return nil
    }
  }
}

struct LockScreenButton: View {
  let number: LockScreenNumber
  
  var body: some View {
    switch number {
    case let .number(value):
      Text("\(value)")
        .adaptiveFont(.latoRegular, size: 32)
        .foregroundColor(.adaptiveWhite)
        .padding(32)
        .background(Color.chambray)
        .clipShape(Circle())
    case .emptyLeft, .emptyRight:
      Text("0")
        .adaptiveFont(.latoRegular, size: 32)
        .foregroundColor(.adaptiveWhite)
        .padding(32)
        .background(Color.clear)
    case .biometric:
      Image(systemName: number.id)
        .adaptiveFont(.latoRegular, size: 32)
        .foregroundColor(.adaptiveWhite)
        .padding(20)
        .background(Color.chambray)
        .clipShape(Circle())
    }
  }
}
