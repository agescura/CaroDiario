import SwiftUI
import ComposableArchitecture
import Views

public struct WelcomeView: View {
	@Perception.Bindable var store: StoreOf<WelcomeFeature>
  
  public init(
    store: StoreOf<WelcomeFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
		WithPerceptionTracking {
			NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
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
						selection: self.$store.selectedPage.sending(\.selectedPage),
						animated: self.store.tabViewAnimated
          )
          .frame(minHeight: 150)
          
          TerciaryButtonView(
            label: {
              Text("OnBoarding.Skip".localized)
                .adaptiveFont(.latoRegular, size: 16)
              
            }) {
							self.store.send(.skipAlertButtonTapped)
            }
						.opacity(self.store.isAppClip ? 0.0 : 1.0)
            .padding(.horizontal, 16)
            .alert(
							store: self.store.scope(state: \.$alert, action: \.alert)
            )
          
          PrimaryButtonView(
            label: {
              Text("OnBoarding.Continue".localized)
                .adaptiveFont(.latoRegular, size: 16)
              
            }) {
							self.store.send(.privacyButtonTapped)
            }
            .padding(.horizontal, 16)
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
			} destination: { store in
				switch store.case {
					case let .layout(store):
						LayoutView(store: store)
					case let .privacy(store):
						PrivacyView(store: store)
					case let .style(store):
						StyleView(store: store)
					case let .theme(store):
						ThemeView(store: store)
				}
			}
      .navigationViewStyle(StackNavigationViewStyle())
      .task {
				await self.store.send(.task).finish()
      }
		}
  }
}

struct WelcomeView_Previews: PreviewProvider {
  static var previews: some View {
    WelcomeView(
      store: Store(
				initialState: WelcomeFeature.State(),
				reducer: { WelcomeFeature() }
      )
    )
  }
}
