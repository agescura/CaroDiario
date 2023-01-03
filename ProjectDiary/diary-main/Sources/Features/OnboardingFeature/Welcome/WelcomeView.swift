import SwiftUI
import ComposableArchitecture
import Views

public struct WelcomeView: View {
  let store: StoreOf<Welcome>
  
  public init(
    store: StoreOf<Welcome>
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
              send: Welcome.Action.selectedPage
            ),
            animated: viewStore.tabViewAnimated
          )
          .frame(minHeight: 150)
          
          TerciaryButtonView(
            label: {
              Text("OnBoarding.Skip".localized)
                .adaptiveFont(.latoRegular, size: 16)
              
            }) {
              viewStore.send(.skipAlertButtonTapped)
            }
            .opacity(viewStore.isAppClip ? 0.0 : 1.0)
            .padding(.horizontal, 16)
            .alert(
              store.scope(state: \.skipAlert),
              dismiss: .cancelSkipAlert
            )
          
          PrimaryButtonView(
            label: {
              Text("OnBoarding.Continue".localized)
                .adaptiveFont(.latoRegular, size: 16)
              
            }) {
              viewStore.send(.navigationPrivacy(true))
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(
          isPresented: viewStore.binding(
            get: \.navigatePrivacy,
            send: Welcome.Action.navigationPrivacy),
          destination: {
            IfLetStore(
              store.scope(
                state: \.privacy,
                action: Welcome.Action.privacy
              ),
              then: PrivacyView.init(store:)
            )
          }
        )
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
        reducer: Welcome()
      )
    )
  }
}
