import ComposableArchitecture
import EntriesFeature
import Models
import Styles
import SwiftUI

public struct LayoutView: View {
  let store: StoreOf<LayoutFeature>
  
  public var body: some View {
	 WithViewStore(self.store, observe: { $0 }) { viewStore in
		
		VStack(alignment: .leading, spacing: 16) {
		  
		  Picker("",  selection: viewStore.binding(
			 get: \.layoutType,
			 send: LayoutFeature.Action.layoutChanged
		  )) {
			 ForEach(LayoutType.allCases, id: \.self) { type in
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
					 action: LayoutFeature.Action.entries(id:action:)),
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
		.navigationBarTitle("Settings.Layout".localized)
	 }
  }
}

struct LayoutView_Previews: PreviewProvider {
	static var previews: some View {
		LayoutView(
			store: Store(
				initialState: LayoutFeature.State(
					layoutType: .vertical,
					styleType: .rectangle,
					entries: fakeEntries(
						with: .rectangle,
						layout: .vertical
					)
				),
				reducer: LayoutFeature()
			)
		)
		.previewDisplayName("Vertical")
		
		LayoutView(
			store: Store(
				initialState: LayoutFeature.State(
					layoutType: .horizontal,
					styleType: .rectangle,
					entries: fakeEntries(
						with: .rectangle,
						layout: .horizontal
					)
				),
				reducer: LayoutFeature()
			)
		)
		.previewDisplayName("Horizontal")
	}
}
