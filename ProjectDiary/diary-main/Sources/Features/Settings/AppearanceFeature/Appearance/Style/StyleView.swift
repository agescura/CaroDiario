import ComposableArchitecture
import SwiftUI
import Styles
import EntriesFeature
import Models

public struct StyleView: View {
	@Perception.Bindable var store: StoreOf<StyleFeature>
  
	public init(
		store: StoreOf<StyleFeature>
	) {
		self.store = store
	}
	
  public var body: some View {
		WithPerceptionTracking {
      VStack(alignment: .leading, spacing: 16) {
        
				Picker("", selection: self.$store.userSettings.appearance.styleType.sending(\.styleChanged)) {
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
      .navigationBarTitle("Settings.Style".localized)
    }
  }
}
