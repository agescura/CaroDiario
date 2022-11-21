import SwiftUI
import ComposableArchitecture
import Views
import SwiftUIHelper

public struct InsertView: View {
  let store: StoreOf<Insert>
  
  public init(
    store: StoreOf<Insert>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack(spacing: 8) {
        Spacer()
        VStack(spacing: 32) {
          Text(viewStore.step.title)
          HStack {
            ForEach(0..<viewStore.maxNumbersCode, id: \.self) { iterator in
              Image(viewStore.code.count > iterator ? .circleFill : .circle)
            }
          }
          if viewStore.codeNotMatched {
            Text("Passcode.Different".localized)
              .foregroundColor(.berryRed)
          }
          Spacer()
        }
        CustomTextField(
          text: viewStore.binding(
            get: \.code,
            send: Insert.Action.update
          ),
          isFirstResponder: true
        )
        .frame(width: 300, height: 50)
        .opacity(0.0)
        
        Spacer()
        SecondaryButtonView(
          label: { Text("Passcode.Dismiss".localized) }
        ) {
          viewStore.send(.popToRoot)
        }
        
        NavigationLink(
          route: viewStore.route,
          case: /Insert.State.Route.menu,
          onNavigate: { viewStore.send(.navigateMenuPasscode($0)) },
          destination: { menuState in
            MenuPasscodeView(
              store: self.store.scope(
                state: { _ in menuState },
                action: Insert.Action.menuPasscodeAction
              )
            )
          },
          label: EmptyView.init
        )
      }
      .padding(16)
      .navigationBarTitle("Passcode.Title".localized, displayMode: .inline)
      .navigationBarBackButtonHidden(true)
      .navigationBarItems(
        leading: Button(
          action: { viewStore.send(.popToRoot) }
        ) {
          HStack { Image(.chevronRight) }
        }
      )
    }
  }
}
