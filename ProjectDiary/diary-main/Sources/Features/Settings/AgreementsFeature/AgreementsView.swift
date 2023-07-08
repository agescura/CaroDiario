import ComposableArchitecture
import Localizables
import SwiftUI
import SwiftUIHelper
import Views

public struct AgreementsView: View {
  private let store: StoreOf<AgreementsFeature>
  
  public init(
    store: StoreOf<AgreementsFeature>
  ) {
    self.store = store
  }
  
  public var body: some View {
	  Form {
		 Section {
			HStack(spacing: 16) {
			  IconImageView(
				 .squareAndArrowUp,
				 foregroundColor: .green
			  )
			  Text(AgreementType.composableArchitecture.title)
				 .foregroundColor(.chambray)
				 .adaptiveFont(.latoRegular, size: 12)
				 .minimumScaleFactor(0.01)
				 .lineLimit(1)
			  Spacer()
			  Image(.chevronRight)
				 .foregroundColor(.adaptiveGray)
			}
			.contentShape(Rectangle())
			.onTapGesture {
			  store.send(.open(.composableArchitecture))
			}
		 }
		 Section {
			HStack(spacing: 16) {
			  IconImageView(
				 .exclamationMarkCircle,
				 foregroundColor: .yellow
			  )
			  Text(AgreementType.pointfree.title)
				 .foregroundColor(.chambray)
				 .adaptiveFont(.latoRegular, size: 12)
				 .minimumScaleFactor(0.01)
				 .lineLimit(1)
			  Spacer()
			  Image(.chevronRight)
				 .foregroundColor(.adaptiveGray)
			}
			.contentShape(Rectangle())
			.onTapGesture {
			  store.send(.open(.pointfree))
			}
			HStack(spacing: 16) {
			  IconImageView(
				 .exclamationMarkCircle,
				 foregroundColor: .yellow
			  )
			  Text(AgreementType.raywenderlich.title)
				 .foregroundColor(.chambray)
				 .adaptiveFont(.latoRegular, size: 12)
			  Spacer()
			  Image(.chevronRight)
				 .foregroundColor(.adaptiveGray)
			}
			.contentShape(Rectangle())
			.onTapGesture {
			  store.send(.open(.raywenderlich))
			}
		 }
	  }
	  .navigationBarTitle("Settings.Agreements".localized)
  }
}
