import ComposableArchitecture
import DesignSystem
import Models
import SwiftUI
import EntriesFeature

public struct ThemeView: View {
  @Bindable var store: StoreOf<ThemeFeature>
  
  public init(
    store: StoreOf<ThemeFeature>
  ) {
    self.store = store
    
    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.chambray)
    UISegmentedControl.appearance().backgroundColor = UIColor(.adaptiveGray).withAlphaComponent(0.1)
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      
      Picker("", selection: $store.userSettings.appearance.themeType.sending(\.themeChanged)) {
        ForEach(ThemeType.allCases, id: \.self) { type in
          Text(type.rawValue.localized)
            .foregroundColor(.berryRed)
            .adaptiveFont(.latoRegular, size: 10)
        }
      }
      .frame(height: 60)
      .pickerStyle(SegmentedPickerStyle())
      
      DayEntriesView(
        dayEntriesRows: .fakeGroupedEntries,
        layoutType: store.userSettings.appearance.layoutType,
        styleType: store.userSettings.appearance.styleType
      )
      .accentColor(.chambray)
      .animation(.default, value: UUID())
      .disabled(true)
      
      Spacer()
    }
    .padding(16)
    .navigationBarTitle("Settings.Theme".localized)
  }
}
