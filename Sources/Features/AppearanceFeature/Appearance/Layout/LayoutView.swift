import ComposableArchitecture
import DesignSystem
import Models
import SwiftUI
import EntriesFeature
import SQLiteDataClient

public struct LayoutView: View {
  @Bindable var store: StoreOf<LayoutFeature>
  
  public init(
    store: StoreOf<LayoutFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      
      Picker("", selection: $store.userSettings.appearance.layoutType.sending(\.layoutChanged)) {
        ForEach(LayoutType.allCases, id: \.self) { type in
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
      .animation(.default, value: store.userSettings.appearance.layoutType)
      .disabled(true)
      
      Spacer()
    }
    .padding(16)
    .navigationBarTitle("Settings.Layout".localized)
  }
}

#Preview {
  LayoutView(
    store: Store(
      initialState: LayoutFeature.State(),
      reducer: { LayoutFeature() }
    )
  )
}
