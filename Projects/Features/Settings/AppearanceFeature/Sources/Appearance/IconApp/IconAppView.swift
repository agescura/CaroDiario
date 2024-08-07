import ComposableArchitecture
import SwiftUI
import Styles
import UIApplicationClient
import Models

public struct IconAppView: View {
	let store: StoreOf<IconAppFeature>
	
	public init(
		store: StoreOf<IconAppFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		ZStack {
			Color.adaptiveGray.opacity(0.1)
				.edgesIgnoringSafeArea(.all)
			
			VStack {
				HStack(spacing: 32) {
					ForEach(IconAppType.allCases, id: \.self) { iconApp in
						VStack {
							Image(iconApp.icon)
								.resizable()
								.frame(maxWidth: .infinity)
								.scaledToFit()
								.clipShape(RoundedRectangle(cornerRadius: 16))
								.onTapGesture {
									self.store.send(.iconAppChanged(iconApp))
								}
								.overlay(
									Text(self.store.userSettings.appearance.iconAppType == iconApp ? "Selected" : "")
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

#Preview {
	IconAppView(
		store: Store(
			initialState: IconAppFeature.State(),
			reducer: { IconAppFeature() }
		)
	)
}
