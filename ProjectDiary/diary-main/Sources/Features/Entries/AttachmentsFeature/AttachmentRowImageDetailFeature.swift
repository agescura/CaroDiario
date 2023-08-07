import ComposableArchitecture
import Foundation
import Models
import SwiftUI

public struct AttachmentRowImageDetailFeature: ReducerProtocol {
	public init() {}
	
	public struct State: Equatable {
		public var currentPosition: CGSize = .zero
		public let entryImage: EntryImage
		public var imageScale: CGFloat = 1
		public var isTapped: Bool = false
		public var lastValue: CGFloat = 1
		@PresentationState public var alert: AlertState<Action.Alert>?
		
		public init(
			entryImage: EntryImage
		) {
			self.entryImage = entryImage
		}
	}
	
	public enum Action: Equatable {
		case alertButtonTapped
		case alert(PresentationAction<Alert>)
		case dragGesture(DragGesture.Value)
		case scaleOnChanged(CGFloat)
		case scaleTapGestureCount
		
		public enum Alert {
			case removeButtonTapped
		}
	}
	
	public var body: some ReducerProtocolOf<Self> {
		Reduce { state, action in
			switch action {
				case .alertButtonTapped:
					state.alert = .remove
					return .none
					
				case .alert:
					return .none
					
				case let .dragGesture(value):
					state.currentPosition = .init(width: value.translation.width, height: value.translation.height)
					return .none

				case let .scaleOnChanged(value):
					let maxScale: CGFloat = 3.0
					let minScale: CGFloat = 1.0
					
					let resolvedDelta = value / state.imageScale
					state.lastValue = value
					let newScale = state.imageScale * resolvedDelta
					state.imageScale = min(maxScale, max(minScale, newScale))
					return .none
					
				case .scaleTapGestureCount:
					state.isTapped.toggle()
					state.imageScale = state.imageScale > 1 ? 1 : 2
					state.currentPosition = .zero
					return .none
					
			}
		}
	}
}

extension AlertState where Action == AttachmentRowImageDetailFeature.Action.Alert {
	static var remove: Self {
		AlertState {
			TextState("Image.Remove.Description".localized)
		} actions: {
			ButtonState.destructive(.init("Image.Remove.Title".localized), action: .send(.removeButtonTapped))
		}
	}
}
