import ComposableArchitecture
import EntriesFeature
import FeedbackGeneratorClient
import Models
import Styles
import SwiftUI
import UserDefaultsClient
import Views

public struct LayoutView: View {
  private let store: StoreOf<Layout>
  
  public init(
    store: StoreOf<Layout>
  ) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        
        ScrollView(showsIndicators: false) {
          VStack(alignment: .leading, spacing: 16) {
            
            Text("OnBoarding.Layout.Title".localized)
              .adaptiveFont(.latoBold, size: 24)
              .foregroundColor(.adaptiveBlack)
            
            Text("OnBoarding.Appearance.Message".localized)
              .adaptiveFont(.latoItalic, size: 10)
              .foregroundColor(.adaptiveGray)
            
            
            Picker("",  selection: viewStore.binding(
              get: \.layoutType,
              send: Layout.Action.layoutChanged
            )) {
              ForEach(LayoutType.allCases, id: \.self) { type in
                Text(type.rawValue.localized)
              }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            LazyVStack(alignment: .leading, spacing: 8) {
              ForEachStore(
                store.scope(
                  state: \.entries,
                  action: Layout.Action.entries(id:action:)),
                content: DayEntriesRowView.init(store:)
              )
            }
            .accentColor(.chambray)
            .animation(.default, value: UUID())
            .disabled(true)
            .frame(minHeight: 200)
            
            NavigationLink(
              "",
              destination:
                IfLetStore(
                  store.scope(
                    state: \.theme,
                    action: Layout.Action.theme
                  ),
                  then: ThemeView.init(store:)
                ),
              isActive: viewStore.binding(
                get: \.navigateTheme,
                send: Layout.Action.navigateTheme)
            )
            .frame(height: 0)
            
          }
        }
        
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
            viewStore.send(.navigateTheme(true))
          }
          .padding(.horizontal, 16)
      }
      .padding()
      .navigationBarBackButtonHidden(true)
    }
  }
}
