import ComposableArchitecture
import SwiftUI
import EntriesFeature
import Views
import Styles
import UserDefaultsClient
import FeedbackGeneratorClient
import Models

public struct LayoutView: View {
  let store: StoreOf<LayoutFeature>
  
  public init(
    store: StoreOf<LayoutFeature>
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
              send: LayoutFeature.Action.layoutChanged
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
                  action: LayoutFeature.Action.entries(id:action:)),
                content: DayEntriesRowView.init(store:)
              )
            }
            .accentColor(.chambray)
            .animation(.default, value: UUID())
            .disabled(true)
            .frame(minHeight: 200)
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
						store: self.store.scope(state: \.$alert, action: { .alert($0) })
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
      .navigationDestination(
        isPresented: viewStore.binding(
          get: \.navigateTheme,
          send: LayoutFeature.Action.navigateTheme
        ),
        destination: {
          IfLetStore(
            store.scope(
              state: \.theme,
              action: LayoutFeature.Action.theme
            ),
            then: ThemeView.init(store:)
          )
        }
      )
    }
  }
}
