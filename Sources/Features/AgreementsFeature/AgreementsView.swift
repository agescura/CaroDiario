import ComposableArchitecture
import DesignSystem
import Localizables
import SwiftUI

public struct AgreementsView: View {
	let store: StoreOf<AgreementsFeature>
	
	public init(
		store: StoreOf<AgreementsFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		Form {
			Section {
        LabeledContent {
          Image(systemName: .chevronRight)
        } label: {
          HStack(spacing: .s16) {
            Image(systemName: .squareAndArrowUp)
              .foregroundColor(.greenPure)
            Text(AgreementType.composableArchitecture.title)
          }
        }
        .labeledContentStyle(.default)
				.contentShape(Rectangle())
				.onTapGesture {
					store.send(.open(.composableArchitecture))
				}
			}
			Section {
        LabeledContent {
          Image(systemName: .chevronRight)
        } label: {
          HStack(spacing: .s16) {
            Image(systemName: .exclamationMarkCircle)
              .foregroundColor(.yellowPure)
            Text(AgreementType.pointfree.title)
          }
        }
        .labeledContentStyle(.default)
        .contentShape(Rectangle())
        .onTapGesture {
          store.send(.open(.pointfree))
        }
        LabeledContent {
          Image(systemName: .chevronRight)
        } label: {
          HStack(spacing: .s16) {
            Image(systemName: .exclamationMarkCircle)
              .foregroundColor(.yellowPure)
            Text(AgreementType.raywenderlich.title)
          }
        }
        .labeledContentStyle(.default)
        .contentShape(Rectangle())
        .onTapGesture {
          store.send(.open(.raywenderlich))
        }
			}
		}
		.navigationBarTitle("Settings.Agreements".localized)
	}
}

#Preview {
  registerFonts()
  return NavigationStack {
    AgreementsView(
      store: Store(initialState: AgreementsFeature.State()) {
        AgreementsFeature()
      }
    )
  }
}

