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
        share: { data in
                .fireAndForget {
                    guard let windowScene = UIApplication.shared.windows.first?.windowScene else { return }
                    
                    let vc = UIActivityViewController(activityItems: [data], applicationActivities: [])
                    
                    let presentedView: UIViewController?
                    if let presented =  windowScene.windows.first?.rootViewController?.presentedViewController {
                        presentedView = presented
                    } else {
                        presentedView = windowScene.windows.first?.rootViewController
                    }
                    
                    presentedView?.present(
                        vc,
                        animated: true,
                        completion: nil
                    )
                    
                }
        }
    )
}


