import SwiftUI
import ComposableArchitecture
import Views

public struct WelcomeView: View {
	@Bindable var store: StoreOf<WelcomeFeature>
	
	public init(
		store: StoreOf<WelcomeFeature>
	) {
		self.store = store
	}
	
	public var body: some View {
		NavigationStack(path: self.$store.scope(state: \.path, action: \.path)) {
			VStack(alignment: .leading, spacing: 16) {
				Text("OnBoarding.Diary".localized)
					.textStyle(.title)
				Text("OnBoarding.Welcome".localized)
					.textStyle(.body)
				
				OnBoardingTabView(
					items: [
						.init(id: 0, title: "OnBoarding.Description.1".localized),
						.init(id: 1, title: "OnBoarding.Description.2".localized),
						.init(id: 2, title: "OnBoarding.Description.3".localized)
					],
					selection: self.$store.selectedPage.sending(\.selectedPage),
					animated: self.store.tabViewAnimated
				)
				.frame(minHeight: 150)
				
				
				Button("OnBoarding.Skip".localized) {
					self.store.send(.skipAlertButtonTapped)
				}
				.buttonStyle(.secondary)
				.opacity(self.store.isAppClip ? 0.0 : 1.0)
				
				Button("OnBoarding.Continue".localized) {
					self.store.send(.privacyButtonTapped)
				}
				.buttonStyle(.primary)
			}
			.padding()
			.navigationBarTitleDisplayMode(.inline)
			.alert(
				store: self.store.scope(state: \.$alert, action: \.alert)
			)
		} destination: { store in
			switch store.case {
				case let .layout(store):
					LayoutView(store: store)
				case let .privacy(store):
					PrivacyView(store: store)
				case let .style(store):
					StyleView(store: store)
				case let .theme(store):
					ThemeView(store: store)
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.task {
			await self.store.send(.task).finish()
		}
	}
}

#Preview {
	WelcomeView(
		store: Store(
			initialState: WelcomeFeature.State(),
			reducer: { WelcomeFeature() }
		)
	)
}

struct PrimaryButtonStyle: ButtonStyle {
	@Environment(\.isEnabled) var isEnabled
	
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding()
			.frame(maxWidth: .infinity)
			.background(Color.chambray)
			.foregroundColor(.adaptiveWhite)
			.cornerRadius(16)
			.opacity(isEnabled ? 1.0 : 0.5)
	}
}

extension ButtonStyle where Self == PrimaryButtonStyle {
	static var primary: Self {
		PrimaryButtonStyle()
	}
}

struct SecondaryButtonStyle: ButtonStyle {
	@Environment(\.isEnabled) var isEnabled
	
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.frame(maxWidth: .infinity)
			.foregroundColor(.chambray)
			.adaptiveFont(.latoRegular, size: 16)
			.opacity(isEnabled ? 1.0 : 0.5)
	}
}

extension ButtonStyle where Self == SecondaryButtonStyle {
	static var secondary: Self {
		SecondaryButtonStyle()
	}
}

protocol TextStyle {
	var font: LatoFonts { get }
	var size: CGFloat { get }
	var foregroundColor: Color { get }
}

struct TitleTextStyle: TextStyle {
	let font: LatoFonts = .latoBold
	let size: CGFloat = 24
	let foregroundColor: Color = .adaptiveBlack
}

struct BodyTextStyle: TextStyle {
	let font: LatoFonts = .latoItalic
	let size: CGFloat = 12
	let foregroundColor: Color = .adaptiveGray
}

extension Text {
	func textStyle(_ style: TextStyle) -> some View {
		self
			.adaptiveFont(style.font, size: style.size)
			.foregroundColor(style.foregroundColor)
	}
}

extension TextStyle where Self == TitleTextStyle {
	static var title: Self { TitleTextStyle() }
}

extension TextStyle where Self == BodyTextStyle {
	static var body: Self { BodyTextStyle() }
}

import Styles

struct Item {
	let name: String
	let color: Color?
	let status: Status
	
	enum Status: Equatable {
		case inStock(quantity: Int)
		case outOfStock(isOnBackOrder: Bool)
		
		var isInStock: Bool {
			guard case .inStock = self else { return false }
			return true
		}
	}
}

enum Navigation {
	case welcome
	case login
	case main(Main)
	
	enum Main {
		case home
		case search
		case settings
	}
}
