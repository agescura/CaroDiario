import ComposableArchitecture
import Models
import Styles
import SwiftUI

public struct IconAppView: View {
  private let store: StoreOf<IconAppFeature>
  
  public init(
	 store: StoreOf<IconAppFeature>
  ) {
	 self.store = store
  }
  
  public var body: some View {
	 WithViewStore(
		self.store,
		observe: \.iconAppType
	 ) { viewStore in
		ZStack {
		  Color.adaptiveGray.opacity(0.1)
			 .edgesIgnoringSafeArea(.all)
		  
		  VStack {
			 HStack(spacing: 32) {
				ForEach(IconAppType.allCases, id: \.self) { iconApp in
				  VStack {
					 Image(iconApp.icon, bundle: .module)
						.resizable()
						.frame(maxWidth: .infinity)
						.scaledToFit()
						.clipShape(RoundedRectangle(cornerRadius: 16))
						.onTapGesture {
						  viewStore.send(.iconAppChanged(iconApp))
						}
						.overlay(
						  Text(viewStore.state == iconApp ? "Selected" : "")
							 .foregroundColor(.chambray)
							 .adaptiveFont(.latoRegular, size: 14)
							 .offset(x: 0, y: 32)
						  ,
						  alignment: .bottom
						)
				  }
				}
			 }
			 
			 Spacer()
		  }
		  .padding()
		}
		.navigationBarTitleDisplayMode(.inline)
	 }
  }
}

struct IconAppView_Previews: PreviewProvider {
	static var previews: some View {
		IconAppView(
			store: Store(
				initialState: IconAppFeature.State(
					iconAppType: .light
				),
				reducer: IconAppFeature()
			)
		)
	}
}

