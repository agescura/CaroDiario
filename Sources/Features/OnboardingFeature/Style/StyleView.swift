import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import Models
import EntriesFeature
import Styles

public struct StyleView: View {
  let store: StoreOf<Style>
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack {
        
        ScrollView(showsIndicators: false) {
          VStack(alignment: .leading, spacing: 16) {
            
            Text("OnBoarding.Style.Title".localized)
              .adaptiveFont(.latoBold, size: 24)
              .foregroundColor(.adaptiveBlack)
            
            Text("OnBoarding.Style.Message".localized)
              .foregroundColor(.adaptiveGray)
              .adaptiveFont(.latoRegular, size: 10)
            
            Picker("",  selection: viewStore.binding(
              get: \.styleType,
              send: Style.Action.styleChanged
            )) {
              ForEach(StyleType.allCases, id: \.self) { type in
                Text(type.rawValue.localized)
                  .foregroundColor(.berryRed)
                  .adaptiveFont(.latoRegular, size: 10)
              }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            LazyVStack(alignment: .leading, spacing: 8) {
              ForEachStore(
                store.scope(
                  state: \.entries,
                  action: Style.Action.entries(id:action:)),
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
            store.scope(state: \.skipAlert),
            dismiss: .cancelSkipAlert
          )
        
        PrimaryButtonView(
          label: {
            Text("OnBoarding.Continue".localized)
              .adaptiveFont(.latoRegular, size: 16)
          }) {
            viewStore.send(.navigationLayout(true))
          }
          .padding(.horizontal, 16)
      }
      .padding()
      .navigationBarBackButtonHidden(true)
      .navigationDestination(
        isPresented: viewStore.binding(
          get: \.navigateLayout,
          send: Style.Action.navigationLayout
        ),
        destination: {
          IfLetStore(
            store.scope(
              state: \.layout,
              action: Style.Action.layout
            ),
            then: LayoutView.init(store:)
          )
        }
      )
    }
  }
}

struct StyleView_Previews: PreviewProvider {
  static var previews: some View {
    StyleView(
      store: .init(
        initialState: .init(
          styleType: .rectangle,
          layoutType: .horizontal,
          entries: fakeEntries(
            with: .rectangle,
            layout: .horizontal
          )
        ),
        reducer: Style())
    )
  }
}
