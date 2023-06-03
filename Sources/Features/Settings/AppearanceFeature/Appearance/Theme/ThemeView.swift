import ComposableArchitecture
import SwiftUI
import Styles
import UserDefaultsClient
import EntriesFeature
import FeedbackGeneratorClient
import Models

public struct ThemeView: View {
  let store: StoreOf<ThemeFeature>
  
  init(
    store: StoreOf<ThemeFeature>
  ) {
    self.store = store
    
    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.chambray)
    UISegmentedControl.appearance().backgroundColor = UIColor(.adaptiveGray).withAlphaComponent(0.1)
  }
  
  public var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack(alignment: .leading, spacing: 16) {
        
        Picker("",  selection: viewStore.binding(
          get: \.themeType,
          send: ThemeFeature.Action.themeChanged
        )) {
          ForEach(ThemeType.allCases, id: \.self) { type in
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
                action: ThemeFeature.Action.entries(id:action:)),
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
      .navigationBarTitle("Settings.Theme".localized)
    }
  }
}
