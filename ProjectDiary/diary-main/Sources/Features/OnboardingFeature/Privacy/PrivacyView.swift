import SwiftUI
import ComposableArchitecture
import Views
import Styles
import EntriesFeature

public struct PrivacyView: View {
  let store: StoreOf<Privacy>
  
  public init(
    store: StoreOf<Privacy>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading, spacing: 16) {
        Text("OnBoarding.Important".localized)
          .adaptiveFont(.latoRegular, size: 24)
          .foregroundColor(.adaptiveBlack)
        
        HStack(alignment: .center) {
          Image(systemName: "hand.raised")
            .resizable()
            .foregroundColor(.adaptiveGray)
            .scaledToFill()
            .frame(width: 18, height: 18)
            .offset(y: 8)
          
          Text("OnBoarding.Privacy".localized)
            .adaptiveFont(.latoItalic, size: 12)
            .foregroundColor(.adaptiveGray)
        }
        
        Spacer()
        
        NavigationLink(
          "",
          destination:
            IfLetStore(
              store.scope(
                state: \.style,
                action: Privacy.Action.style
              ),
              then: StyleView.init(store:)
            ),
          isActive: viewStore.binding(
            get: \.navigateStyle,
            send: Privacy.Action.navigationStyle
          )
        )
        
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
            viewStore.send(.navigationStyle(true))
          }
          .padding(.horizontal, 16)
      }
      .padding()
      .navigationBarBackButtonHidden(true)
    }
  }
}
