import Foundation
import LocalAuthentication
import Models
import Dependencies

extension LocalAuthenticationClient: DependencyKey {
	public static var liveValue: LocalAuthenticationClient { .live }
}

extension LocalAuthenticationClient {
	
	public static var live: Self {
		let context = LAContext()
		
		return Self(
			determineType: {
				await withCheckedContinuation { [context] continuation in
					var type = LocalAuthenticationType.none
					var error: NSError?
					guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
						continuation.resume(with: .success(.none))
						return
					}
					switch context.biometryType {
						case .touchID:
							type = .touchId
						case .faceID:
							type = .faceId
						default:
							type = .none
					}
					continuation.resume(with: .success(type))
				}
			},
			evaluate: { reason in
				await withCheckedContinuation { [context] continuation in
					context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
						continuation.resume(with: .success(success))
					}
				}
			}
		)
	}
}
