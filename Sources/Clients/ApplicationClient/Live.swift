import UIKit
import Dependencies

extension ApplicationClient: DependencyKey {
  public static var liveValue: ApplicationClient { .live }
}

extension ApplicationClient {
  public static var live: ApplicationClient {
    ApplicationClient(
      open: { @MainActor in await UIApplication.shared.open($0, options: $1) },
      openSettings: { @MainActor in await UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:]) },
      setAlternateIconName: { @MainActor iconName in
        try await UIApplication.shared.setAlternateIconName(iconName)
      },
      setUserInterfaceStyle: { userInterfaceStyle in
        await MainActor.run {
          guard
            let scene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene })
              as? UIWindowScene
          else { return }
          scene.keyWindow?.overrideUserInterfaceStyle = userInterfaceStyle
        }
      },
      share: { data, position in
        let windowScene = UIApplication.shared.connectedScenes
          .filter { $0.activationState == .foregroundActive }
          .compactMap { $0 as? UIWindowScene }.first
        
        guard let windowScene = windowScene else { return }
        
        let vc = UIActivityViewController(activityItems: [data], applicationActivities: [])
        
        let presentedView: UIViewController?
        if let presented =  windowScene.windows.first?.rootViewController?.presentedViewController {
          presentedView = presented
        } else {
          presentedView = windowScene.windows.first?.rootViewController
        }
        
        if let popoverController = vc.popoverPresentationController {
          popoverController.sourceRect = CGRect(x: position.x, y: position.y, width: 0, height: 0)
          popoverController.sourceView = windowScene.keyWindow?.rootViewController?.view
          popoverController.permittedArrowDirections = .up
        }
        
        presentedView?.present(
          vc,
          animated: true,
          completion: nil
        )
      },
    )
  }
}

extension ApplicationClient.PopoverPosition {
  
  var x: CGFloat {
    switch self {
    case .attachment:
      UIScreen.main.bounds.width - 74
    case .text:
      UIScreen.main.bounds.width -  16
    case .pdf:
      0
    }
  }
  
  var y: CGFloat {
    switch self {
    case .attachment, .text:
      70
    case .pdf:
      270
    }
  }
}
