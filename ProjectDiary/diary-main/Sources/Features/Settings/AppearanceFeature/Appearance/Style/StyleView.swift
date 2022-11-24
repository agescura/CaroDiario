import ComposableArchitecture
import SwiftUI
import Styles
import EntriesFeature
import Models

public struct StyleView: View {
  let store: StoreOf<Style>
  
  public var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading, spacing: 16) {
        
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
        .frame(height: 60)
        .pickerStyle(SegmentedPickerStyle())
        
        ScrollView(showsIndicators: false) {
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
        }
        
        Spacer()
      }
      .padding(16)
      .navigationBarTitle("Settings.Style".localized)
    }
  }
}
