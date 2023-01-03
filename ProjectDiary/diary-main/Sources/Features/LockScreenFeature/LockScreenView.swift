import SwiftUI
import ComposableArchitecture
import Styles
import Views
import Localizables
import Models

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
