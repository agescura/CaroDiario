//
//  Live.swift  
//
//  Created by Albert Gil Escura on 28/7/21.
//

import Combine
import UIKit
import UIApplicationClient

extension UIApplicationClient {
    public static let live = Self(
        alternateIconName: UIApplication.shared.alternateIconName,
        setAlternateIconName: { iconName in
                .run { subscriber in
                    UIApplication.shared.setAlternateIconName(iconName) { error in
                        if let error = error {
                            subscriber.send(completion: .failure(error))
                        } else {
                            subscriber.send(completion: .finished)
                        }
                    }
                    return AnyCancellable {}
                }
        },
        supportsAlternateIcons: { UIApplication.shared.supportsAlternateIcons },
        openSettings: {
            .fireAndForget {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
            }
        },
        open: { url, options in
                .fireAndForget {
                    UIApplication.shared.open(url, options: options)
                }
        },
        canOpen: {
            UIApplication.shared.canOpenURL($0)
        },
        share: { data, position in
                .fireAndForget {
                    guard let windowScene = UIApplication.shared.windows.first?.windowScene else { return }
                    
                    let vc = UIActivityViewController(activityItems: [data], applicationActivities: [])
                    
                    let presentedView: UIViewController?
                    if let presented =  windowScene.windows.first?.rootViewController?.presentedViewController {
                        presentedView = presented
                    } else {
                        presentedView = windowScene.windows.first?.rootViewController
                    }
                    
                    if let popoverController = vc.popoverPresentationController {
                        popoverController.sourceRect = CGRect(x: position.x, y: position.y, width: 0, height: 0)
                        popoverController.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
                        popoverController.permittedArrowDirections = .up
                    }
                    
                    presentedView?.present(
                        vc,
                        animated: true,
                        completion: nil
                    )
                    
                }
        },
        showTabView: { isShowing in
                .fireAndForget {
                    UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.allSubviews().forEach({ (v) in
                        if let view = v as? UITabBar {
                            view.isHidden = isShowing
                        }
                    })
                }
        }
    )
}

extension UIView {
    func allSubviews() -> [UIView] {
        var res = subviews
        for subview in subviews {
            let riz = subview.allSubviews()
            res.append(contentsOf: riz)
        }
        return res
    }
}

extension UIApplicationClient.PopoverPosition {
    
    var x: CGFloat {
        switch self {
        case .attachment:
            return UIScreen.main.bounds.width - 74
        case .text:
            return UIScreen.main.bounds.width -  16
        case .pdf:
            return 0
        }
    }
    
    var y: CGFloat {
        switch self {
        case .attachment, .text:
            return 70
        case .pdf:
            return 270
        }
    }
}
