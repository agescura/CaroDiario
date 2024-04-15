import ComposableArchitecture
import SwiftUI
import Styles
import UserDefaultsClient
import EntriesFeature
import FeedbackGeneratorClient
import Models

public struct ThemeView: View {
	@Perception.Bindable var store: StoreOf<ThemeFeature>
  
  public init(
    store: StoreOf<ThemeFeature>
  ) {
    self.store = store
    
    UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(.chambray)
    UISegmentedControl.appearance().backgroundColor = UIColor(.adaptiveGray).withAlphaComponent(0.1)
  }
  
  public var body: some View {
		WithPerceptionTracking {
      VStack(alignment: .leading, spacing: 16) {
        
				Picker("", selection: self.$store.userSettings.appearance.themeType.sending(\.themeChanged)) {
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
						ForEach(
							Array(self.store.scope(state: \.entries, action: \.entries)),
							id: \.id
						) { store in
							WithPerceptionTracking {
								DayEntriesRowView(store: store)
							}
						}
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
