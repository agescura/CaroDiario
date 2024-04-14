import SwiftUI
import ComposableArchitecture
import Styles
import Views
import Localizables
import Models

public struct LockScreenView: View {
  let store: StoreOf<LockScreenFeature>
  private let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
  ]
  
  public init(
    store: StoreOf<LockScreenFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
		WithPerceptionTracking {
      VStack(spacing: 16) {
        Spacer()
        Text("LockScreen.Title".localized)
        HStack {
					ForEach(0..<(self.store.userSettings.passcode?.count ?? 0), id: \.self) { iterator in
						WithPerceptionTracking {
							Image(systemName: self.store.codeToMatch.count > iterator ? "circle.fill" : "circle")
						}
          }
        }
        .modifier(ShakeGeometryEffect(animatableData: CGFloat(self.store.wrongAttempts)))
        Spacer()
        LazyVGrid(columns: columns) {
          ForEach(self.store.buttons) { item in
						WithPerceptionTracking {
							Button(
								action: {
									self.store.send(.numberButtonTapped(item), animation: .default)
								},
								label: {
									LockScreenButton(number: item)
								}
							)
						}
          }
        }
        .padding(.horizontal)
        Spacer()
      }
      .onAppear {
				self.store.send(.onAppear)
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
