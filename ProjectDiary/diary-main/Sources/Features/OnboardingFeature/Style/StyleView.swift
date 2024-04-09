import ComposableArchitecture
import SwiftUI
import Views
import Localizables
import Models
import EntriesFeature
import Styles

public struct StyleView: View {
	@Perception.Bindable var store: StoreOf<StyleFeature>
  
  public var body: some View {
		WithPerceptionTracking {
      VStack {
        ScrollView(showsIndicators: false) {
          VStack(alignment: .leading, spacing: 16) {
            
            Text("OnBoarding.Style.Title".localized)
              .adaptiveFont(.latoBold, size: 24)
              .foregroundColor(.adaptiveBlack)
            
            Text("OnBoarding.Style.Message".localized)
              .foregroundColor(.adaptiveGray)
              .adaptiveFont(.latoRegular, size: 10)
            
						Picker("", selection: self.$store.userSettings.appearance.styleType.sending(\.styleChanged)
            ) {
              ForEach(StyleType.allCases, id: \.self) { type in
                Text(type.rawValue.localized)
                  .foregroundColor(.berryRed)
                  .adaptiveFont(.latoRegular, size: 10)
              }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            LazyVStack(alignment: .leading, spacing: 8) {
							ForEach(
								self.store.scope(state: \.entries, action: \.entries),
								id: \.id
							) { store in
								DayEntriesRowView(store: store)
							}
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
						self.store.send(.skipAlertButtonTapped)
          }
          .opacity(self.store.isAppClip ? 0.0 : 1.0)
          .padding(.horizontal, 16)
          .alert(
						store: self.store.scope(state: \.$alert, action: \.alert)
          )
        
        PrimaryButtonView(
          label: {
            Text("OnBoarding.Continue".localized)
              .adaptiveFont(.latoRegular, size: 16)
          }) {
						self.store.send(.layoutButtonTapped)
          }
          .padding(.horizontal, 16)
      }
      .padding()
      .navigationBarBackButtonHidden(true)
    }
  }
}

#Preview {
	StyleView(
		store: .init(
			initialState: StyleFeature.State(
				entries: fakeEntries
			),
			reducer: { StyleFeature() }
		)
	)
}
