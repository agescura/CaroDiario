import ComposableArchitecture
import Foundation
import UIApplicationClient

enum MailType: String {
	case mail = "mailto"
	case gmail = "googlemail"
	case outlook = "ms-outlook"
}

@Reducer
public struct AboutFeature {
	public init() {}
	
	@ObservableState
	public struct State: Equatable {
		@Presents public var dialog: ConfirmationDialogState<Action.Dialog>?
		
		public init() {}
	}
	
	public enum Action: Equatable {
		case confirmationDialogButtonTapped
		case dialog(PresentationAction<Dialog>)
		
		@CasePathable
		public enum Dialog: Equatable {
			case mail
			case gmail
			case outlook
		}
	}
	
	@Dependency(\.applicationClient) private var applicationClient
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
				case .confirmationDialogButtonTapped:
					state.dialog = .dialog
					return .none
					
				case .dialog(.presented(.mail)):
					return .run { _ in
						var components = URLComponents()
						components.scheme = "mailto"
						components.path = "carodiarioapp@gmail.com"
						components.queryItems = [
							URLQueryItem(name: "subject", value: "Bug in Caro Diario"),
							URLQueryItem(name: "body", value: "<Explain your bug here>"),
						]
						await self.applicationClient.open(components.url!, [:])
					}
					
				case .dialog(.presented(.gmail)):
					return .run { _ in
						let compose = "googlegmail:///co?subject=Bug in Caro Diario&body=<Explain your bug here>&to=carodiarioapp@gmail.com"
							.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
						let url = URL(string: compose)!
						await self.applicationClient.open(url, [:])
					}
					
				case .dialog(.presented(.outlook)):
					return .run { _ in
						let compose = "ms-outlook://compose?to=carodiarioapp@gmail.com&subject=Bug in Caro Diario&body=<Explain your bug here>"
							.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
						let url = URL(string: compose)!
						await self.applicationClient.open(url, [:])
					}
					
				case .dialog:
					return .none
			}
		}
		.ifLet(\.$dialog, action: \.dialog)
	}
}

extension ConfirmationDialogState where Action == AboutFeature.Action.Dialog {
	public static var dialog: Self {
		ConfirmationDialogState {
			TextState("AddEntry.ChooseOption".localized)
		} actions: {
			ButtonState(action: .send(.mail)) {
				TextState("Apple Mail")
			}
			ButtonState(action: .send(.gmail)) {
				TextState("Google Gmail")
			}
			ButtonState(action: .send(.outlook)) {
				TextState("Microsoft Outlook")
			}
		}
	}
}
