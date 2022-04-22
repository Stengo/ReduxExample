import Foundation
import UIKit

func viewControllerPresentationSideEffect() -> SideEffect {
    return SideEffect {[
        *\.wordSelection
    ]} newFragmentCallback: { fragment in
        if
            fragment.containsChanges(for: \.wordSelection),
            case let .selected(word) = fragment.wordSelection,
            word.lowercased() == "success"
        {
            guard let topMostViewController = UIApplication.shared.topMostViewController else {
                return
            }
            topMostViewController.present(SuccessViewController(), animated: true, completion: nil)
        }
    }
}

private extension UIApplication {
    var topMostViewController: UIViewController? {
        guard
            let activeScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let window = activeScene.keyWindow
        else {
            return nil
        }
        return window.rootViewController?.topMostViewController
    }
}

private extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController ?? navigation
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }

        return self
    }
}
