import SwiftUI
import ComposableArchitecture
import Views

public struct WelcomeView: View {
  let store: StoreOf<WelcomeFeature>
  
  public init(
    store: StoreOf<WelcomeFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      NavigationStack {
        VStack(alignment: .leading, spacing: 16) {
          Text("OnBoarding.Diary".localized)
            .adaptiveFont(.latoBold, size: 24)
            .foregroundColor(.adaptiveBlack)
          Text("OnBoarding.Welcome".localized)
            .adaptiveFont(.latoItalic, size: 12)
            .foregroundColor(.adaptiveGray)
          
          
          OnBoardingTabView(
            items: [
              .init(id: 0, title: "OnBoarding.Description.1".localized),
              .init(id: 1, title: "OnBoarding.Description.2".localized),
              .init(id: 2, title: "OnBoarding.Description.3".localized)
            ],
            selection: viewStore.binding(
              get: \.selectedPage,
              send: WelcomeFeature.Action.selectedPage
            ),
            animated: viewStore.tabViewAnimated
          )
          .frame(minHeight: 150)
          
          TerciaryButtonView(
            label: {
              Text("OnBoarding.Skip".localized)
                .adaptiveFont(.latoRegular, size: 16)
              
            }) {
              viewStore.send(.alertButtonTapped)
            }
            .opacity(viewStore.isAppClip ? 0.0 : 1.0)
            .padding(.horizontal, 16)
          
          PrimaryButtonView(
            label: {
              Text("OnBoarding.Continue".localized)
                .adaptiveFont(.latoRegular, size: 16)
              
            }) {
              viewStore.send(.privacyButtonTapped)
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .alert(
          store: self.store.scope(
            state: \.$alert,
            action: WelcomeFeature.Action.alert
          )
        )
        .navigationDestination(
          store: self.store.scope(
            state: \.$privacy,
            action: WelcomeFeature.Action.privacy
          )
        ) { store in
          PrivacyView(store: store)
        }
      }
      .navigationViewStyle(StackNavigationViewStyle())
      .onAppear {
        viewStore.send(.startTimer)
      }
    }
  }
}

struct WelcomeView_Previews: PreviewProvider {
  static var previews: some View {
    WelcomeView(
      store: .init(
        initialState: .init(),
        reducer: WelcomeFeature()
      )
    )
  }
}
