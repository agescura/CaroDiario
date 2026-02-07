import ComposableArchitecture
import DesignSystem
import SwiftUI
import Models
import EntriesFeature

public struct StyleView: View {
  @Bindable var store: StoreOf<StyleFeature>
  
  public init(
    store: StoreOf<StyleFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      
      Picker("", selection: $store.userSettings.appearance.styleType.sending(\.styleChanged)) {
        ForEach(StyleType.allCases, id: \.self) { type in
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
    .navigationBarTitle("Settings.Style".localized)
  }
}
